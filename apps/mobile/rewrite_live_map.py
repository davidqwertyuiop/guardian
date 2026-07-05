import re

base_dir = "lib/features/location/presentation/screens"
with open(f"{base_dir}/live_map_screen.dart", "r") as f:
    content = f.read()

imports_match = re.search(r'(.*?)^const String _darkMapStyle', content, re.MULTILINE | re.DOTALL)
if not imports_match:
    imports_match = re.search(r'(.*?)^class LiveMapScreen', content, re.MULTILINE | re.DOTALL)

imports_code = imports_match.group(1).strip() if imports_match else ""

screen_class_match = re.search(r'(class LiveMapScreen extends StatefulWidget.*?^})', content, re.MULTILINE | re.DOTALL)
screen_class = screen_class_match.group(1) if screen_class_match else ""

state_class_match = re.search(r'(class _LiveMapScreenState extends State<LiveMapScreen>.*?^})', content, re.MULTILINE | re.DOTALL)
state_class = state_class_match.group(1) if state_class_match else ""

new_content = imports_code + """
import '../../domain/models/live_map_models.dart';
import '../widgets/live_map/map_card.dart';
import '../widgets/live_map/top_bar.dart';

""" + screen_class + "\n\n" + state_class + "\n"

# Replace private usages inside _LiveMapScreenState
new_content = new_content.replace('_TopBar(', 'LiveMapTopBar(')
new_content = new_content.replace('_MapCard(', 'MapCard(')

with open(f"{base_dir}/live_map_screen.dart", "w") as f:
    f.write(new_content)

print("Rewrote live_map_screen.dart")
