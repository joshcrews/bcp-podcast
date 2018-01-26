# date = Date.utc_today()
# Bcp.EpisodeBuilder.build(date)

defmodule Bcp.EpisodeBuilder do

  alias Bcp.Repo

  def build(date) do
    %{date: date}
    |> build_api_request_url()
    |> fetch_api_response()
    |> set_passage_names()
    |> label_passage_names()
    |> set_passage_texts()
    |> order_passages()
    |> set_episode_full_name()
    |> set_episode_full_text()
    |> get_audio_mp3_files()
    |> stitch_together_final_mp3_file()
    |> upload_mp3_file()
    |> calculate_duration()
    |> commit_episode_to_database()
    :finished
  end


  def build_api_request_url(params = %{date: date}) do
    request_url = EsvApi.build_request(date)
    Map.put(params, :request_url, request_url)
  end

  def fetch_api_response(params = %{request_url: request_url}) do
    case HTTPotion.get(request_url) do
      %{status_code: 200, body: body} ->
        IO.inspect(body, label: :esv_response)
        Map.put(params, :api_response_html, body)
    end
  end

  def set_passage_names(params = %{api_response_html: api_response_html}) do
    passage_names = Floki.find(api_response_html, "h2")
                    |> Enum.map(fn(h2) -> Floki.text(h2) end)
                    |> Enum.map(fn(text) -> String.replace(text, " (Listen)", "") end)

    Map.put(params, :passage_names, passage_names)
  end

  def set_passage_texts(params = %{api_response_html: api_response_html, passage_names: passage_names}) do
    passage_texts = Floki.find(api_response_html, ".esv-text")
                    |> Enum.map(fn(chapter) -> 
                      chapter_num_text = Floki.find(chapter, ".chapter-num") |> Floki.text()
                      Floki.text(chapter) 
                      |> String.replace(chapter_num_text, "")
                      |> String.replace(".", ". ")
                    end)

    passage_text_mappings = Enum.with_index(passage_names)
                            |> Enum.map(fn({name, index}) -> 
                              text = Enum.at(passage_texts, index)
                              {name, text}
                            end)
                            |> Enum.into(%{})
  
    Map.put(params, :passage_text_mappings, passage_text_mappings)
    |> Map.delete(:api_response_html)
  end

  def label_passage_names(params) do
    params
    |> copy_passage_names()
    |> pluck_psalms()
    |> pluck_gospel()
    |> pluck_nt()
    |> pluck_ot()
    |> set_morning_psalms()
  end

  def order_passages(params = %{passage_text_mappings: passage_text_mappings}) do
    ordered_passages = [
                          params.morning_psalms,
                          params.ot,
                          params.nt,
                          params.gospel,
                          params.evening_psalms,
                        ]
                        |> List.flatten()
                        |> IO.inspect(label: :ordered_passages)

    ordered_passage_text_mappings = Enum.map(ordered_passages, fn(passage_name) -> 
            Enum.find(passage_text_mappings, fn({name, _text}) -> 
              passage_name == name
            end)
          end)

    Map.put(params, :ordered_passages, ordered_passages)
    |> Map.put(:passage_text_mappings, ordered_passage_text_mappings)
  end

  def set_episode_full_name(params = %{ordered_passages: ordered_passages}) do
    episode_full_name = Enum.join(ordered_passages, "; ")
    Map.put(params, :episode_full_name, episode_full_name)
  end

  def set_episode_full_text(params = %{passage_text_mappings: passage_text_mappings}) do
    IO.inspect(passage_text_mappings, label: :passage_text_mappings)
    full_text = Enum.map(passage_text_mappings, fn({passage_name, text}) -> 
      ~s"""
#{passage_name}

#{text}



"""
    end)
    |> Enum.join("\n")

    Map.put(params, :episode_full_text, full_text)
  end

  def get_audio_mp3_files(params = %{passage_text_mappings: passage_text_mappings}) do
    audio_files = Bcp.AudioFiles.find_passages(passage_text_mappings)
    Map.put(params, :audio_files, audio_files)
  end

  def stitch_together_final_mp3_file(params = %{episode_full_name: episode_full_name, audio_files: audio_files, date: date}) do
    output_path = "mp3s/output/#{date}.mp3"
    Bcp.StitchAudioFilesTogether.build(episode_full_name, audio_files, output_path)
    Map.put(params, :output_path, output_path)
  end

  def upload_mp3_file(params = %{date: date, output_path: output_path}) do
    s3_key = "episodes/#{date}.mp3"
    binary = File.read!(output_path)

    {:ok, s3_url} = Bcp.S3Upload.s3_upload(s3_key, binary)

    Map.put(params, :s3_url, s3_url)
  end

  def calculate_duration(params) do
    params
  end

  def commit_episode_to_database(params = %{s3_url: s3_url, date: date, episode_full_name: episode_full_name, episode_full_text: episode_full_text}) do
    %Bcp.Episode{mp3_url: s3_url, date: date, passages: episode_full_name, passage_text: episode_full_text}
    |> Repo.insert!

    params
  end

  def copy_passage_names(params = %{passage_names: passage_names}) do
    Map.put(params, :copied_passage_names, passage_names)
  end

  def pluck_psalms(params = %{copied_passage_names: passage_names}) do
    psalms = Enum.filter(passage_names, &(String.match?(&1, ~r/Psalm/)))
    new_passage_names = Enum.filter(passage_names, &(!Enum.member?(psalms, &1)))

    Map.put(params, :copied_passage_names, new_passage_names)
    |> Map.put(:psalms, psalms)
  end

  def pluck_gospel(params = %{copied_passage_names: passage_names}) do
    gospel = Enum.filter(passage_names, fn(name) ->
        String.match?(name, ~r/Matthew|Mark|Luke|John/) && !String.match?(name, ~r/(1 John|2 John|3 John)/)
    end)
    new_passage_names = Enum.filter(passage_names, &(!Enum.member?(gospel, &1)))

    Map.put(params, :copied_passage_names, new_passage_names)
    |> Map.put(:gospel, gospel)
  end

  def pluck_nt(params = %{copied_passage_names: passage_names}) do
    nt = Enum.filter(passage_names, fn(name) ->
      String.match?(name, ~r/(Acts|Romans|Corinthians|Corinthians|Galatians|Ephesians|Philippians|Colossians|Thessalonians|Timothy|Titus|Philemon|Hebrews|James|Peter|Peter|1 John|2 John|3 John|Jude|Revelation)/)
    end)
    new_passage_names = Enum.filter(passage_names, &(!Enum.member?(nt, &1)))

    Map.put(params, :copied_passage_names, new_passage_names)
    |> Map.put(:nt, nt)
  end

  def pluck_ot(params = %{copied_passage_names: passage_names}) do
    Map.put(params, :copied_passage_names, [])
    |> Map.put(:ot, passage_names)
  end

  def set_morning_psalms(params = %{psalms: psalms}) do
    half = Enum.count(psalms) |> div(2)
    [morning_psalms, evening_psalms] = Enum.chunk(psalms, half)

    Map.put(params, :morning_psalms, morning_psalms)
    |> Map.put(:evening_psalms, evening_psalms)
  end
  
end