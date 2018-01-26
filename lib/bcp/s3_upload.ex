
defmodule Bcp.S3Upload do
  
  def s3_upload(s3_key, binary) do
    {:ok, bucket} = Application.fetch_env(:ex_aws, :mp3_bucket)
    s3_options = [acl: :public_read]
    url = url(s3_key, bucket)

    case ExAws.request!(ExAws.S3.put_object(bucket, s3_key, binary, s3_options)) do
      %{status_code: 200}     -> {:ok, url}
      %{status_code: _, body: body} -> {:error, body}
    end
  end

  def url(path, bucket) do
    "https://s3.amazonaws.com/#{bucket}/#{path}"
  end

end