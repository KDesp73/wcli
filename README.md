# weathercli

**weathercli** is a command-line tool that displays weather information in a concise and visually appealing format.

Get your API key from [weatherapi.com](https://www.weatherapi.com/).

---

![Screenshot of weathercli output](https://github.com/user-attachments/assets/59434c03-0150-445d-b1d2-596d37d3f848)

## Installation

### Manual

```bash
git clone https://github.com/KDesp73/weathercli && weathercli
sudo zig build install
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
