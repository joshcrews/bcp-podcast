# Daily Office Lectionary Podcast, Text-to-Speech Australian accent

`#elixir, #aws-polly, #ffmpeg, #postgres, #phoenix, #ecto, #s3`

## Podcast URL

[https://bcp-podcast.herokuapp.com/podcast.xml](https://bcp-podcast.herokuapp.com/podcast.xml)

## What it does

1. ESV Bible API is called for the Daily Office lectionary reading plan for today's date
2. The readings are sorted into
  * Morning Psalms
  * Old Testament
  * New Testament
  * Gospels
  * Evening Psalms
3. The Bible texts are formatted from HTML to text.
4. The texts are transformed into SSML, "speak markup language"
5. The speak markup language files are sent to Amazon Polly (Text to Speech) service, where a Australian accented robot reads the text
6. The passages (text and mp3) are saved to Amazon S3
7. All the passages are joined together into one single mp3 file using FFMpeg
8. The one single mp3 file is uploaded to Amazon S3
9. The new mp3 file is added to the podcast




## Phoenix

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
