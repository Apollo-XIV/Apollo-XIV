import facet
import filepath
import gleam/io
import gleam/option
import gleam/result
import gleam_community/ansi
import jot
import simplifile
import tom

pub type Post {
  Post(title: String, date: String, path: String, content: String)
}

pub fn list_posts(posts_dir: String) -> List(String) {
  simplifile.read_directory(posts_dir)
  |> result.unwrap([])
}

pub fn get_post(paths_dir: String, path: String) -> Result(Post, Nil) {
  paths_dir
  |> filepath.join(path)
  |> simplifile.read
  |> result.nil_error
  |> result.try(fn(x) {
    x
    |> facet.parse
    |> result.nil_error
  })
  // error if theres no frontmatter
  |> result.try(fn(document) {
    case document.frontmatter {
      // returns the frontmatter and document content in a tuple
      option.Some(f) -> Ok(#(f.content, document.content))
      option.None -> Error(Nil)
    }
  })
  |> result.try(fn(document_pair) {
    Ok({
      let #(frontmatter, content) = document_pair
      let assert Ok(meta) = tom.parse(frontmatter)
      let assert Ok(post_title) = tom.get_string(meta, ["title"])
      let assert Ok(date) = tom.get_string(meta, ["date"])
      let content = jot.to_html(content)
      Post(post_title, date, path, content)
    })
  })
  |> result.map_error(fn(_e) {
    "Couldn't fetch post data"
    |> ansi.red
    |> io.println
  })
}
