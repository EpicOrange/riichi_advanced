import json
import sys

def pretty_format_json(data, indent=2, max_width=80, array_chunk_size=8):
    """Pretty format JSON to respect max line width while not exceeding it."""
    def _is_simple_value(val):
        """Return True if the value is a simple type that can be placed inline."""
        return isinstance(val, (str, int, float)) or val is None or val is True or val is False
    
    def _format_simple_value(val):
        return json.dumps(val)
    
    def _format_list(lst, level):
        """Format a list, placing multiple items per line when possible."""
        indented = " " * (level * indent)
        item_lines = []
        current_line = []
        current_length = 0

        for item in lst:
            item_str = _format_value(item, level + 1)
            if len(current_line) < array_chunk_size and (current_length + len(item_str)) < max_width:
                current_line.append(item_str)
                current_length += len(item_str) + 2  # Account for ", " between items
            else:
                # Start a new line
                if current_line:
                    item_lines.append(f"{indented}{', '.join(current_line)}")
                current_line = [item_str]
                current_length = len(item_str)

        if current_line:
            item_lines.append(f"{indented}{', '.join(current_line)}")

        if len(lst) == 0:
            return "[]"
        elif len(item_lines) == 1:
            return f"[{', '.join(current_line)}]"
        else:
            return "[\n" + ",\n".join(item_lines) + "\n" + " " * (indent * (level - 1)) + "]"

    def _format_object(obj, level):
        """Format a dictionary, attempting to keep it compact where possible."""
        indented = " " * (level * indent)
        items = [f"{json.dumps(k)}: {_format_value(v, level + 1)}" for k, v in obj.items()]
        if sum(len(item) for item in items) + len(obj) - 1 <= max_width - len(indented):
            return f"{{{', '.join(items)}}}"
        else:
            return "{\n" + ",\n".join([f"{indented}{item}" for item in items]) + "\n" + " " * (indent * (level - 1)) + "}"
    
    def _format_value(val, level):
        if _is_simple_value(val):
            return _format_simple_value(val)
        elif isinstance(val, list):
            return _format_list(val, level)
        elif isinstance(val, dict):
            return _format_object(val, level)
        else:
            return json.dumps(val)  # Fallback
    
    return _format_value(data, 1)


def format_json_from_file(filepath, indent=2, max_width=80, array_chunk_size=8):
    """Read JSON from file, format it, and print the result."""
    try:
        with open(filepath, 'r') as file:
            json_data = json.load(file)
            pretty_json = pretty_format_json(json_data, indent=indent, max_width=max_width)
            print(pretty_json)
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python script.py <input_file> [indent] [max_width]")
        sys.exit(1)
    
    filepath = sys.argv[1]
    indent = int(sys.argv[2]) if len(sys.argv) > 2 else 2
    max_width = int(sys.argv[3]) if len(sys.argv) > 3 else 80
    array_chunk_size = int(sys.argv[4]) if len(sys.argv) > 4 else 8
    
    format_json_from_file(filepath, indent=indent, max_width=max_width, array_chunk_size=array_chunk_size)
