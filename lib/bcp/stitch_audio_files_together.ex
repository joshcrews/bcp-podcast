defmodule Bcp.StitchAudioFilesTogether do

  def build(episode_full_name, audio_files, output_path) do
    audio_files = List.flatten(audio_files)
    file_names = Enum.map(audio_files, &(save_locally/1))
    
    file_chain = Enum.join(file_names, "|")
    concat = "concat:#{file_chain}" |> IO.inspect()

    # ffmpeg -i "concat:file1.mp3|silence5.mp3|file2.mp3" -acodec copy output.mp3
    System.cmd "ffmpeg", ["-i", concat, "-metadata", "title=#{episode_full_name}", "-metadata", "author=ESV", "-acodec", "copy", output_path, "-y"] |> IO.inspect(label: :system_cmd)
  end

  def build_passage(passages_s3_urls, output_path) do
    IO.inspect(passages_s3_urls, label: :passages_s3_urls)
    passages_local_files = Enum.map(passages_s3_urls, &(save_locally/1))

    file_chain = Enum.join(passages_local_files, "|")

    concat = "concat:#{file_chain}" |> IO.inspect()

    System.cmd "ffmpeg", ["-i", concat, "-acodec", "copy", output_path, "-y"] |> IO.inspect(label: :system_cmd)
  end

  def save_locally(url) do
    IO.inspect({:get, url})
    case HTTPotion.get(url, [timeout: 30_000]) do
      %{status_code: 200, body: body} ->
        file_name = String.split(url, "/") |> Enum.reverse() |> List.first()
        file_name = "mp3s/#{file_name}"
        File.write!(file_name, body)
        file_name
    end
  end
  
end