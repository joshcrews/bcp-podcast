defmodule Bcp.Web.PodcastView do
  use Bcp.Web, :view

  def episode_title(episode) do
    "#{episode.date} - #{episode.passages}"
  end

  def episode_link(episode) do
    episode.mp3_url
    ""
  end

  def episode_guid(episode) do
    episode.date
  end

  def episode_description(episode) do
    ~s"""
#{episode.passage_text}


Scripture taken from The Holy Bible, English Standard Version.
Copyright 2001 by Crossway Bibles ( http://www.crosswaybibles.org ), a publishing ministry of Good News Publishers. Used by
permission. All rights reserved. Text provided by the Crossway
Bibles Web Service ( http://www.gnpcb.org/esv/share/services/ )
"""
  end

  def episode_pub_date(episode) do
    episode.inserted_at
    |> pub_date()
  end

  def pub_date(datetime) do
    datetime
    |> NaiveDateTime.to_erl()
    |> rfc2822()
  end

  def episode_mp3_url(episode) do
    episode.mp3_url
  end

  def episode_duration(episode) do
    133629
  end

  def rfc2822({{year, month, day} = date, {hour, minute, second}}) do
    weekday_name  = weekday_name(:calendar.day_of_the_week(date))
    month_name    = month_name(month)
    padded_day    = pad(day)
    padded_hour   = pad(hour)
    padded_minute = pad(minute)
    padded_second = pad(second)
    binary_year   = Integer.to_string(year)

    weekday_name <> ", " <> padded_day <>
      " " <> month_name <> " " <> binary_year <>
      " " <> padded_hour <> ":" <> padded_minute <>
      ":" <> padded_second <> " GMT"
  end

  defp weekday_name(1), do: "Mon"
  defp weekday_name(2), do: "Tue"
  defp weekday_name(3), do: "Wed"
  defp weekday_name(4), do: "Thu"
  defp weekday_name(5), do: "Fri"
  defp weekday_name(6), do: "Sat"
  defp weekday_name(7), do: "Sun"

  defp month_name(1),  do: "Jan"
  defp month_name(2),  do: "Feb"
  defp month_name(3),  do: "Mar"
  defp month_name(4),  do: "Apr"
  defp month_name(5),  do: "May"
  defp month_name(6),  do: "Jun"
  defp month_name(7),  do: "Jul"
  defp month_name(8),  do: "Aug"
  defp month_name(9),  do: "Sep"
  defp month_name(10), do: "Oct"
  defp month_name(11), do: "Nov"
  defp month_name(12), do: "Dec"

  defp pad(number) when number in 0..9, do: <<?0, ?0 + number>>
  defp pad(number), do: Integer.to_string(number)

  
end
