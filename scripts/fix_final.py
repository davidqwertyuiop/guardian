import re

with open('lib/features/location/presentation/screens/live_map_screen.dart', 'r') as f:
    content = f.read()

# Fix am.AnnotationId consts
content = content.replace('const am.AnnotationId(', 'am.AnnotationId(')
content = content.replace('const am.InfoWindow(', 'am.InfoWindow(')
content = content.replace('const am.PolylineId(', 'am.PolylineId(')

# Remove unused _LocationPin
content = re.sub(r'class _LocationPin extends StatelessWidget \{.*?\}\n\}', '', content, flags=re.DOTALL)

# Remove unused _AvatarPin
content = re.sub(r'class _AvatarPin extends StatelessWidget \{.*?\}\n\}', '', content, flags=re.DOTALL)

with open('lib/features/location/presentation/screens/live_map_screen.dart', 'w') as f:
    f.write(content)
