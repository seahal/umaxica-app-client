use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(name = "umaxica-apps-cli", version, about = "Umaxica CLI tool")]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand)]
enum Commands {
    /// Show version information
    Info,
}

fn main() {
    let cli = Cli::parse();

    match cli.command {
        Some(Commands::Info) => {
            println!("umaxica-apps-cli v{}", env!("CARGO_PKG_VERSION"));
        }
        None => {
            println!("umaxica-apps-cli v{}", env!("CARGO_PKG_VERSION"));
            println!("Use --help for usage information.");
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use clap::Parser;

    #[test]
    fn cli_parses_no_args() {
        let cli = Cli::try_parse_from(["umaxica-apps-cli"]);
        assert!(cli.is_ok());
        assert!(cli.unwrap().command.is_none());
    }

    #[test]
    fn cli_parses_info() {
        let cli = Cli::try_parse_from(["umaxica-apps-cli", "info"]).unwrap();
        assert!(matches!(cli.command, Some(Commands::Info)));
    }
}
