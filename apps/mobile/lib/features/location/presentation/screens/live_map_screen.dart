import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:guardian/export.dart';
import '../../domain/models/live_map_models.dart';
import '../widgets/live_map/broadcast_bottom_panel.dart';
import '../widgets/live_map/broadcast_controls.dart';
import '../widgets/live_map/map_card.dart';
import '../widgets/live_map/place_suggestions_overlay.dart';
import '../widgets/live_map/sos_bottom_sheet.dart';
import '../widgets/live_map/top_bar.dart';
import '../widgets/live_map/welcome_header.dart';
import '../widgets/live_map/circle_card.dart';
import '../widgets/live_map/heading_out_button.dart';

part 'live_map/live_map_controller.dart';
part 'live_map/live_map_actions.dart';
part 'live_map/live_map_sheets.dart';
part 'live_map/live_map_layout.dart';
part 'live_map/live_map_sections.dart';
part 'live_map/live_map_home_sections.dart';
part 'live_map/live_map_top_overlay.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen>
    with TickerProviderStateMixin {
  late final HomeBloc _bloc;
  late final AnimationController _mapAnim;
  late final AnimationController _fullAnim;
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _mapsApiKey = '';
  List<LivePlace> _suggestions = [];
  SelectedLivePlace? _selectedPlace;
  bool _isSearching = false;
  double _broadcastPanelHeight = 260;
  bool _isLocalSosActive = false;
  String? _activeSosBroadcastId;
  String? _activeSosAddress;
  bool _isHomeScrolled = false;

  void updateUi(VoidCallback callback) => setState(callback);

  @override
  void initState() {
    super.initState();
    _bloc = context.read<HomeBloc>()..add(const LoadHomeData());
    _mapAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fullAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scrollController.addListener(handleScroll);
    fetchMapKeys();
  }

  @override
  void dispose() {
    _mapAnim.dispose();
    _fullAnim.dispose();
    _scrollController
      ..removeListener(handleScroll)
      ..dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      bloc: _bloc,
      listener: syncMapAnimations,
      child: BlocBuilder<HomeBloc, HomeState>(
        bloc: _bloc,
        builder: (context, state) => buildLiveMapLayout(state),
      ),
    );
  }
}
