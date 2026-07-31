import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/qr_code_model.dart';
import '../../data/repositories/qr_repository.dart';

// ── Events ──
abstract class QREvent extends Equatable {
  const QREvent();
  @override
  List<Object?> get props => [];
}

class QRScanRequested extends QREvent {
  final String code;
  const QRScanRequested({required this.code});
  @override
  List<Object?> get props => [code];
}

class QRListRequested extends QREvent {}

class QRStatsRequested extends QREvent {}

class QRReset extends QREvent {}

// ── States ──
abstract class QRState extends Equatable {
  const QRState();
  @override
  List<Object?> get props => [];
}

class QRInitial extends QRState {}

class QRScanning extends QRState {}

class QRScanSuccess extends QRState {
  final QRScanResult result;
  const QRScanSuccess({required this.result});
  @override
  List<Object?> get props => [result];
}

class QRScanError extends QRState {
  final String message;
  const QRScanError({required this.message});
  @override
  List<Object?> get props => [message];
}

class QRListLoading extends QRState {}

class QRListLoaded extends QRState {
  final List<QRCodeModel> codes;
  const QRListLoaded({required this.codes});
  @override
  List<Object?> get props => [codes];
}

class QRStatsLoaded extends QRState {
  final QRCodeStats stats;
  const QRStatsLoaded({required this.stats});
  @override
  List<Object?> get props => [stats];
}

// ── BLoC ──
class QRBloc extends Bloc<QREvent, QRState> {
  final QRRepository _repository;

  QRBloc({required QRRepository repository})
      : _repository = repository,
        super(QRInitial()) {
    on<QRScanRequested>(_onScan);
    on<QRListRequested>(_onList);
    on<QRStatsRequested>(_onStats);
    on<QRReset>((_, emit) => emit(QRInitial()));
  }

  Future<void> _onScan(QRScanRequested event, Emitter<QRState> emit) async {
    emit(QRScanning());
    try {
      final result = await _repository.scanQRCode(event.code);
      emit(QRScanSuccess(result: result));
    } catch (e) {
      emit(QRScanError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onList(QRListRequested event, Emitter<QRState> emit) async {
    emit(QRListLoading());
    try {
      final codes = await _repository.listQRCodes();
      emit(QRListLoaded(codes: codes));
    } catch (e) {
      emit(QRScanError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onStats(QRStatsRequested event, Emitter<QRState> emit) async {
    emit(QRListLoading());
    try {
      final stats = await _repository.getStats();
      emit(QRStatsLoaded(stats: stats));
    } catch (e) {
      emit(QRScanError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
