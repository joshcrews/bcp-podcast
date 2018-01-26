defmodule ExAws.Polly do
  @moduledoc """
  Operations on AWS Polly

  ### Examples
  ```
  ExAws.Polly.synthesize_speech("Hello world") |> ExAws.request!()
  ExAws.Polly.synthesize_speech("Hello world", "Emma") |> ExAws.request!()
  ```
  """
  # @api_version_date "2012-09-25"
  @api_version_date "v1"

  ########################
  ### Pipeline Actions ###
  ########################

  @doc "Send text for to convert mp3"
  def synthesize_speech(text, voice_id \\ "Russell") do
    params = %{
       "OutputFormat" => "mp3",
       "Text" => text,
       "TextType" => "ssml",
       "VoiceId" => voice_id
    }
    request(:post, "/speech", params)
  end

  defp request(:get, path, data) do
    %ExAws.Operation.JSON{
      http_method: :get,
      path: "/" <> @api_version_date <> path,
      params: data,
      service: :polly
    }
  end

  defp request(http_method, path, data) do
    %ExAws.Operation.Polly{
      http_method: http_method,
      path: "/" <> @api_version_date <> path,
      data: data,
      service: :polly
    }
  end

end