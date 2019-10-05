lines = IO.stream(:stdio, :line)

all_chunks = fn path ->
  {:ok, binary} = File.read(path)
  {:ok, _, chunks} = :beam_lib.all_chunks(binary)
  chunks
end

decode_chunks = fn chunks ->
  for {chunk_id, data} <- chunks do
    try do
      {chunk_id, :erlang.binary_to_term(data)}
    rescue
      _ -> {chunk_id, data}
    end
  end
end


beam_diff = fn path1, path2 ->
  chunks1 = all_chunks.(path1)
  chunks2 = all_chunks.(path2)

  diff1 = chunks1 -- chunks2
  diff2 = chunks2 -- chunks1

  {decode_chunks.(diff1), decode_chunks.(diff2)}
end

Enum.each(lines, fn
  "Only in " <> _ = line ->
    IO.puts line

  line ->
    case Regex.named_captures(~r/Files (?<path1>.*) and (?<path2>.*) differ/, line) do
      nil ->
        :noop

      %{"path1" => path1, "path2" => path2} ->
        if String.ends_with?(path1, ".beam") do
          IO.inspect beam_diff.(path1, path2), printable_limit: :infinity, limit: :infinity
        else
          IO.puts line
        end
    end
end)
