fn hw() -> String {
    String::from("Hello, Client!")
}

fn main() {
    println!("{}", hw());
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn it_works() {
        assert_eq!(hw(), String::from("Hello, Client!"));
    }
}
