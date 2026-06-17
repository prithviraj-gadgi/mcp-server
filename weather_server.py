import requests
from mcp.server.fastmcp import FastMCP

mcp = FastMCP(name="weather", port=8080)


@mcp.tool()
async def get_weather(location: str) -> dict:
    """Get weather for location."""
    response = requests.get(f'https://wttr.in/{location}?format=j1')
    return response.json()


if __name__ == "__main__":
    mcp.run(transport="streamable-http")
