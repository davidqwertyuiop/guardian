import os
import re

base_dir = "lib/features/location/presentation/screens"
widgets_dir = "lib/features/location/presentation/widgets/live_map"
models_dir = "lib/features/location/domain/models"

os.makedirs(widgets_dir, exist_ok=True)
os.makedirs(models_dir, exist_ok=True)

with open(f"{base_dir}/live_map_screen.dart", "r") as f:
    content = f.read()

def extract_class(content, class_name, is_stateful=False):
    pattern = r'(class ' + class_name + r' (?:extends|implements).*?^})'
    match = re.search(pattern, content, re.MULTILINE | re.DOTALL)
    if not match:
        return ""
    cls_code = match.group(1)
    
    if is_stateful:
        state_pattern = r'(class _' + class_name.lstrip('_') + r'State extends State<' + class_name + r'>.*?^})'
        state_match = re.search(state_pattern, content, re.MULTILINE | re.DOTALL)
        if state_match:
            cls_code += "\n\n" + state_match.group(1)
    
    return cls_code

def extract_const(content, const_name):
    pattern = r'(const String ' + const_name + r' = \'\'\'.*?\'\'\';)'
    match = re.search(pattern, content, re.MULTILINE | re.DOTALL)
    if not match:
        return ""
    return match.group(1)

imports = """import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart' as am;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:guardian/export.dart';
import 'package:geolocator/geolocator.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';
"""

# Models
mock_place = extract_class(content, "MockPlace")
live_place = extract_class(content, "LivePlace")
selected_live_place = extract_class(content, "SelectedLivePlace")

with open(f"{models_dir}/live_map_models.dart", "w") as f:
    f.write(imports + "\n")
    f.write(mock_place + "\n\n" + live_place + "\n\n" + selected_live_place + "\n")

# Map Styles
dark_style = extract_const(content, "_darkMapStyle").replace('_darkMapStyle', 'darkMapStyle')
light_style = extract_const(content, "_lightMapStyle").replace('_lightMapStyle', 'lightMapStyle')

with open(f"{widgets_dir}/map_styles.dart", "w") as f:
    f.write(dark_style + "\n\n" + light_style + "\n")

# Address Text
address_text = extract_class(content, "_AddressText", is_stateful=True).replace('_AddressText', 'AddressText')
with open(f"{widgets_dir}/address_text.dart", "w") as f:
    f.write(imports + "\n" + address_text + "\n")

# Welcome Header
welcome_header = extract_class(content, "_WelcomeHeader").replace('_WelcomeHeader', 'WelcomeHeader')
with open(f"{widgets_dir}/welcome_header.dart", "w") as f:
    f.write(imports + "\n" + welcome_header + "\n")

# Map Distance Badge
map_distance_badge = extract_class(content, "_MapDistanceBadge").replace('_MapDistanceBadge', 'MapDistanceBadge')
with open(f"{widgets_dir}/map_distance_badge.dart", "w") as f:
    f.write(imports + "\n" + map_distance_badge + "\n")

# Circle Card
circle_card = extract_class(content, "_CircleCard").replace('_CircleCard', 'CircleCard')
with open(f"{widgets_dir}/circle_card.dart", "w") as f:
    f.write(imports + "\n" + circle_card + "\n")

# Member Avatar Row
member_avatar_row = extract_class(content, "_MemberAvatarRow").replace('_MemberAvatarRow', 'MemberAvatarRow')
with open(f"{widgets_dir}/member_avatar_row.dart", "w") as f:
    f.write(imports + "\n" + member_avatar_row + "\n")

# Heading Out Button
heading_out = extract_class(content, "_HeadingOutButton").replace('_HeadingOutButton', 'HeadingOutButton')
with open(f"{widgets_dir}/heading_out_button.dart", "w") as f:
    f.write(imports + "\n" + heading_out + "\n")

# Top Bar
top_bar = extract_class(content, "_TopBar").replace('_TopBar', 'LiveMapTopBar')
with open(f"{widgets_dir}/top_bar.dart", "w") as f:
    f.write(imports + "\n" + top_bar + "\n")

# Map Card
map_card = extract_class(content, "_MapCard", is_stateful=True).replace('_MapCard', 'MapCard')
map_card = map_card.replace('_darkMapStyle', 'darkMapStyle').replace('_lightMapStyle', 'lightMapStyle')
map_card = map_card.replace('_MapDistanceBadge', 'MapDistanceBadge')
with open(f"{widgets_dir}/map_card.dart", "w") as f:
    f.write(imports + "\n")
    f.write("import 'map_styles.dart';\n")
    f.write("import 'map_distance_badge.dart';\n")
    f.write("import '../../../../domain/models/live_map_models.dart';\n\n")
    f.write(map_card + "\n")

print("Files successfully generated.")
