import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn list_posts(posts_dir: String) -> List(String) {
  simplifile.read_directory(posts_dir)
  |> result.unwrap([])
  |> list.filter_map(fn(s: String) {
    s
    |> string.split(".")
    |> list.first
  })
  // |> fn(x) {
  //   x
  //   |> list.each(io.println)
  //   x
  // }
}
