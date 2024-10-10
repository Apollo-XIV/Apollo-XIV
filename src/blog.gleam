import argv
import build
import serve

pub fn main() {
  let _ = case argv.load().arguments {
    ["build"] -> build.main()
    _ -> serve.main()
  }
}
