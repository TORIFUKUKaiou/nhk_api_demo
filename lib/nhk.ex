defmodule Nhk do
  @moduledoc """
  Documentation for `Nhk`.
  """

  @area Application.get_env(:nhk, :area)
  @acts Application.get_env(:nhk, :acts)
  @titles Application.get_env(:nhk, :titles)
  @slack_incoming_webbook_url Application.get_env(:nhk, :slack_incoming_webbook_url)
  @slack_channel Application.get_env(:nhk, :slack_channel)

  @doc """
  Hello world.

  ## Examples

      iex> Nhk.hello()
      :world

  """
  def hello do
    :world
  end

  def run do
    first = Timex.now("Asia/Tokyo") |> Timex.to_date()
    last = first |> Timex.shift(days: 7) |> Timex.to_date()
    dates = Date.range(first, last) |> Enum.map(&Date.to_string/1)

    for service <- services(), date <- dates do
      {service, date}
    end
    |> Flow.from_enumerable()
    |> Flow.partition()
    |> Flow.flat_map(fn {service, date} ->
      Nhk.Api.get(@area, service, date)
    end)
    |> Flow.filter(fn %{"act" => act, "title" => title} ->
      favorite_act?(act) || favorite_title?(title)
    end)
    |> Flow.map(fn %{
                     "act" => act,
                     "service" => %{"name" => service_name},
                     "start_time" => start_time,
                     "title" => title
                   } ->
      {"#{start_time}(#{service_name})\n#{title}\n#{act} ", start_time}
    end)
    |> Enum.to_list()
    |> Enum.sort_by(fn {_, start_time} -> start_time end)
    |> Enum.map(fn {txt, _} -> txt end)
    |> Enum.join("\n\n")
    |> post()
  end

  defp services do
    ["g1", "e1", "e4", "s1", "s3", "r1", "r2", "r3"]
  end

  defp favorite_act?(act) do
    String.split(@acts, ",")
    |> Enum.any?(&String.contains?(act, &1))
  end

  defp favorite_title?(title) do
    String.split(@titles, ",")
    |> Enum.any?(&String.contains?(title, &1))
  end

  defp post("") do
    post("探してる番組・出演者はありませんでした。")
  end

  defp post(text) do
    body =
      %{
        text: text,
        username: "NHK番組取得お知らせ",
        icon_emoji: ":ghost:",
        link_names: 1,
        channel: @slack_channel
      }
      |> Jason.encode!()

    headers = [{"Content-type", "application/json"}]
    HTTPoison.post!(@slack_incoming_webbook_url, body, headers)
  end
end
