defmodule EsvApi do

  def build_request(date) do
    api_key = Application.get_env(:bcp, :esv_api_key) |> IO.inspect(label: :api_key)
    "http://www.esvapi.org/v2/rest/readingPlanQuery?key=#{api_key}&date=#{date}&reading-plan=bcp&include-short-copyright=false&include-first-verse-numbers=false&include-verse-numbers=false&include-footnotes=false&include-passage-references=true&audio-version=mm&audio-format=mp3&include-headings=false&include-subheadings=false&include-verse-numbers=false&include-word-ids=false"
  end
  
end