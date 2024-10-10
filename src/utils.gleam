import gleam/io

pub fn dbg(str: String) -> String {
  str
  |> io.println
  str
}
