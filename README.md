# weathercli

**weathercli** is a command-line tool that displays weather information in a concise and visually appealing format.

Get your API key from [weatherapi.com](https://www.weatherapi.com/).

---

![2025-07-09-153247_hyprshot](https://github.com/user-attachments/assets/93ec91ea-23a7-4275-bda0-2dce573098a0)


## Installation

### Manual

```bash
git clone https://github.com/KDesp73/weathercli && weathercli
sudo zig build install-local
```

## API Key

To use `weathercli`, you must set the `WEATHER_API_KEY` environment variable. You can do this in a few ways:

```bash
# Temporary (shell session only)
export WEATHER_API_KEY="your-api-key"

# Permanent (add to ~/.bashrc or ~/.zshrc)
export WEATHER_API_KEY="your-api-key"

# Alternatively, use an alias
alias weathercli='WEATHER_API_KEY="your-api-key" weathercli'
```

## Usage

Run the tool from your terminal:

```bash
weathercli [options]
```

To see all available options and usage instructions:

```bash
weathercli --help
```

## License

This project is licensed under the [MIT License](./LICENSE).
