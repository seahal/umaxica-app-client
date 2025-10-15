fn hw() -> String {
    return String::from("Hello, Client!");
}

fn main() {
    println!("{}", hw());
}

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(crate::hw(), String::from("Hello, Client!"));
    }
}
