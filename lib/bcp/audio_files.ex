# passage_name = "Psalm 139:18-23"
# text = "O Lord, you have searched me and known me!\n\n You know when I sit down and when I rise up;\nyou discern my thoughts from afar. \n\n You search out my path and my lying down\nand are acquainted with all my ways. \n\n Even before a word is on my tongue,\nbehold, O Lord, you know it altogether. \n\n You hem me in, behind and before,\nand lay your hand upon me. \n\n Such knowledge is too wonderful for me;\nit is high; I cannot attain it. Where shall I go from your Spirit?\nOr where shall I flee from your presence?\n\n If I ascend to heaven, you are there!\nIf I make my bed in Sheol, you are there!\n\n If I take the wings of the morning\nand dwell in the uttermost parts of the sea,\n\n even there your hand shall lead me,\nand your right hand shall hold me. \n\n If I say, “Surely the darkness shall cover me,\nand the light about me be night,”\n\n even the darkness is not dark to you;\nthe night is bright as the day,\nfor darkness is as light with you. For you formed my inward parts;\nyou knitted me together in my mother's womb. \n\n I praise you, for I am fearfully and wonderfully made. \n\nWonderful are your works;\nmy soul knows it very well. \n\n My frame was not hidden from you,\n\nwhen I was being made in secret,\nintricately woven in the depths of the earth. \n\n Your eyes saw my unformed substance;\n\nin your book were written, every one of them,\nthe days that were formed for me,\nwhen as yet there was none of them. How precious to me are your thoughts, O God!\nHow vast is the sum of them!"
# Bcp.AudioFiles.create_passage({passage_name, text})

defmodule Bcp.AudioFiles do
  alias Bcp.Repo

  def find_passages(passages) do
    Enum.map(passages, fn({passage_name, text}) -> 
      find_mp3_url({passage_name, text})
    end)
  end

  def find_mp3_url({passage_name, text}) do
    case Repo.get_by(Bcp.Passage, %{name: passage_name}) do
      nil ->
        create_passage({passage_name, text})
      found ->
        found.mp3_url
    end
  end

  def create_passage({passage_name, text}) do
    paramaterized_passage_name = Regex.split(~r/\W/, passage_name)
                                |> Enum.join("-")
                                |> String.downcase

    %{
      paramaterized_passage_name: paramaterized_passage_name,
      text: text,
      passage_name: passage_name
    }
    |> split_passages()
    |> build_ssml_speech_files()
    |> text_to_speech_passages()
    |> concat_mp3_files()
    |> upload_mp3_file()
    |> commit_to_database()
    |> return_mp3_url()
  end

  def split_passages(params = %{text: text}) do
    split_passages = split_passage_into_chunks(text)
    Map.put(params, :split_passages, split_passages)
  end

  def build_ssml_speech_files(params = %{passage_name: passage_name, split_passages: split_passages}) do

    [first_split | remaining_splits] = split_passages

    total_passages_size = Enum.count(split_passages)

    remaining_splits = Enum.with_index(remaining_splits)
                       |> Enum.map(fn({text, index}) -> 
      position = if index + 2 == total_passages_size, do: :final, else: :not_final

      {text, position}
    end)

    first_speech_file = build_first_speech_file(passage_name, first_split, total_passages_size)                       

    remaining_speech_files = Enum.map(remaining_splits, &(build_remaining_split/1))

    split_speech_files = [first_speech_file] ++ remaining_speech_files

    Map.put(params, :split_speech_files, split_speech_files)
  end

  def text_to_speech_passages(params = %{split_speech_files: split_speech_files, paramaterized_passage_name: paramaterized_passage_name}) do

    s3_urls = split_speech_files
              |> Enum.with_index()
              |> Enum.map(fn({text_chunk, index}) -> 
                text_to_speech(text_chunk, index + 1, paramaterized_passage_name)
              end)

    Map.put(params, :passages_s3_urls, s3_urls)
  end

  def concat_mp3_files(params = %{
                            passages_s3_urls: passages_s3_urls, 
                            paramaterized_passage_name: paramaterized_passage_name,
                          }) do

    output_path = "mp3s/output/#{paramaterized_passage_name}.mp3"

    Bcp.StitchAudioFilesTogether.build_passage(passages_s3_urls, output_path)

    Map.put(params, :output_path, output_path)
  end

  def upload_mp3_file(params = %{paramaterized_passage_name: paramaterized_passage_name, output_path: output_path}) do
    s3_key = "passages/esv/1/#{paramaterized_passage_name}.mp3"
    binary = File.read!(output_path)

    {:ok, s3_url} = Bcp.S3Upload.s3_upload(s3_key, binary)

    Map.put(params, :whole_passage_s3_url, s3_url)
  end

  def commit_to_database(params = %{passage_name: passage_name, whole_passage_s3_url: whole_passage_s3_url, text: text}) do
    %Bcp.Passage{name: passage_name, mp3_url: whole_passage_s3_url, text: text}
    |> Repo.insert!

    params
  end

  def return_mp3_url(%{whole_passage_s3_url: whole_passage_s3_url}) do
    whole_passage_s3_url
  end

  def text_to_speech(text_chunk, index, paramaterized_passage_name) do
    binary = ExAws.Polly.synthesize_speech(text_chunk) |> ExAws.request!()
    
    s3_key = "passages/esv/1/#{paramaterized_passage_name}--#{index}.mp3"

    {:ok, s3_url} = Bcp.S3Upload.s3_upload(s3_key, binary)

    s3_url
  end

  def split_passage_into_chunks(text) do
    IO.inspect({String.length(text), text}, label: :split_passage_into_chunks)
    if String.length(text) > 1400 do
      split_this_text(text)
    else
      [text]
    end
  end

  def split_this_text(text) do
    sentences = String.split(text, ~r/(\. |\.\n)/) |> IO.inspect(label: :sentences)
    half = Enum.max([1, div(Enum.count(sentences), 2)])
    [first_half, second_half] = Enum.chunk(sentences, half)

    [
      Enum.join(first_half, ". "),
      Enum.join(second_half, ". "),
    ]
    |> Enum.map(&split_passage_into_chunks/1)
    |> List.flatten()
  end

  def build_first_speech_file(passage_name, text, 1) do
    ~s"""
<speak>
  <break time="3s"/>
  #{passage_name}
  <break time="3s"/>
  #{text}
  <break time="5s"/>
</speak>
"""    
  end

  def build_first_speech_file(passage_name, text, _) do
    ~s"""
<speak>
  <break time="3s"/>
  #{passage_name}
  <break time="3s"/>
  #{text}
  <break time="2s"/>
</speak>
"""    
  end

  def build_remaining_split({text, :final}) do
    ~s"""
<speak>
  #{text}
  <break time="5s"/>
</speak>
"""
  end

  def build_remaining_split({text, _}) do
    ~s"""
<speak>
  #{text}
  <break time="2s"/>
</speak>
"""
  end

  
end