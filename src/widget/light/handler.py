import asyncio
import colorsys
import sys
from tapo import ApiClient

USAGE = "Usage: script.py <ip> <email> <password> on|off|color <r> <g> <b>|brightness <0-100>"

async def set_color(device, r: int, g: int, b: int) -> None:
    h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
    await device.set_hue_saturation(
        hue=round(h * 360),
        saturation=round(s * 100)
    )

async def main() -> None:
    args = sys.argv[1:]
    if len(args) < 4:
        print(USAGE, file=sys.stderr)
        sys.exit(1)

    ip, email, password, command, *rest = args

    try:
        device = await ApiClient(email, password).l900(ip)
    except Exception as e:
        print(f"Failed to connect to device at {ip}: {e}", file=sys.stderr)
        sys.exit(1)

    try:
        match command:
            case "info":
                info = await device.get_device_info_json()
                print(info)
            case "on":
                await device.on()
            case "off":
                await device.off()
            case "color":
                if len(rest) < 3:
                    raise ValueError("color requires r g b arguments")
                r, g, b = (int(x) for x in rest[:3])
                if not all(0 <= x <= 255 for x in (r, g, b)):
                    raise ValueError("RGB values must be 0-255")
                await set_color(device, r, g, b)
            case "brightness":
                if not rest:
                    raise ValueError("brightness requires a value argument")
                brightness = int(rest[0])
                if not 0 <= brightness <= 100:
                    raise ValueError("Brightness must be 0-100")
                await device.set_brightness(brightness)
            case _:
                raise ValueError(f"Unknown command: {command!r}. {USAGE}")
    except ValueError as e:
        print(f"Invalid arguments: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Command '{command}' failed: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main())