import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/blocs.dart';
import 'services/services.dart';
import 'screens/screens.dart';
import 'utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化服务
  final databaseService = DatabaseService();
  final settingsService = SettingsService();
  final networkService = NetworkService();
  final cloudService = CloudService(
    databaseService: databaseService,
    settingsService: settingsService,
    networkService: networkService,
  );

  // 获取正在进行的练习
  final runningRecord = await databaseService.getRunningRecord();

  runApp(PracticeTimerApp(
    databaseService: databaseService,
    settingsService: settingsService,
    networkService: networkService,
    cloudService: cloudService,
    runningRecord: runningRecord,
  ));
}

class PracticeTimerApp extends StatelessWidget {
  final DatabaseService databaseService;
  final SettingsService settingsService;
  final NetworkService networkService;
  final CloudService cloudService;
  final dynamic runningRecord;

  const PracticeTimerApp({
    super.key,
    required this.databaseService,
    required this.settingsService,
    required this.networkService,
    required this.cloudService,
    this.runningRecord,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DatabaseService>.value(value: databaseService),
        RepositoryProvider<SettingsService>.value(value: settingsService),
        RepositoryProvider<NetworkService>.value(value: networkService),
        RepositoryProvider<CloudService>.value(value: cloudService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AppBloc(
              settingsService: settingsService,
              networkService: networkService,
              cloudService: cloudService,
            )..add(const AppInitialized()),
          ),
          BlocProvider(
            create: (context) => TimerBloc(
              databaseService: databaseService,
              settingsService: settingsService,
            )..add(TimerLoaded(runningRecord: runningRecord)),
          ),
          BlocProvider(
            create: (context) => StatsBloc(
              databaseService: databaseService,
            ),
          ),
        ],
        child: BlocBuilder<AppBloc, AppState>(
          builder: (context, appState) {
            return MaterialApp(
              title: '琴时',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: appState.themeMode,
              home: const MainScreen(),
            );
          },
        ),
      ),
    );
  }
}
