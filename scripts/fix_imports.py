import os

screen_file = "lib/features/location/presentation/screens/live_map_screen.dart"
with open(screen_file, "r") as f:
    content = f.read()

content = content.replace('_WelcomeHeader(', 'WelcomeHeader(')
content = content.replace('_CircleCard(', 'CircleCard(')
content = content.replace('_HeadingOutButton()', 'HeadingOutButton()')
content = content.replace("import '../widgets/live_map/top_bar.dart';",
    "import '../widgets/live_map/top_bar.dart';\n" +
    "import '../widgets/live_map/welcome_header.dart';\n" +
    "import '../widgets/live_map/circle_card.dart';\n" +
    "import '../widgets/live_map/heading_out_button.dart';\n")

with open(screen_file, "w") as f:
    f.write(content)


circle_card_file = "lib/features/location/presentation/widgets/live_map/circle_card.dart"
with open(circle_card_file, "r") as f:
    content = f.read()
content = content.replace('_MemberAvatarRow(', 'MemberAvatarRow(')
content = "import 'member_avatar_row.dart';\n" + content
with open(circle_card_file, "w") as f:
    f.write(content)


map_card_file = "lib/features/location/presentation/widgets/live_map/map_card.dart"
with open(map_card_file, "r") as f:
    content = f.read()
content = "import 'package:guardian/features/location/services/gps_service.dart';\n" + content
content = "import 'package:http/http.dart' as http;\n" + content
content = content.replace("import '../../../../domain/models/live_map_models.dart';", "import '../../../domain/models/live_map_models.dart';")
with open(map_card_file, "w") as f:
    f.write(content)
