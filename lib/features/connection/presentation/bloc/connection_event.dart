// lib/features/connection/presentation/bloc/connection_event.dart
import 'package:equatable/equatable.dart';
import '../../../../core/constants/connection_constants.dart';
import '../../domain/entities/connection_entity.dart';

abstract class ConnectionEvent extends Equatable {
  const ConnectionEvent();

  @override
  List<Object?> get props => [];
}

// Connection Info Events
class LoadConnectionInfo extends ConnectionEvent {
  const LoadConnectionInfo();
}

class UpdateDeviceName extends ConnectionEvent {
  final String deviceName;

  const UpdateDeviceName({required this.deviceName});

  @override
  List<Object?> get props => [deviceName];
}

// Discovery Events
class StartDiscovery extends ConnectionEvent {
  final List<ConnectionType> connectionTypes;
  final bool enableAdvertising;

  const StartDiscovery({
    this.connectionTypes = const [
      ConnectionType.wifiDirect,
      ConnectionType.bluetooth,
      ConnectionType.wifiHotspot,
    ],
    this.enableAdvertising = true,
  });

  @override
  List<Object?> get props => [connectionTypes, enableAdvertising];
}

class StopDiscovery extends ConnectionEvent {
  const StopDiscovery();
}

class EndpointFound extends ConnectionEvent {
  final String endpointId;
  final String deviceName;
  final String deviceType;

  const EndpointFound({
    required this.endpointId,
    required this.deviceName,
    required this.deviceType,
  });

  @override
  List<Object?> get props => [endpointId, deviceName, deviceType];
}

class EndpointLost extends ConnectionEvent {
  final String endpointId;

  const EndpointLost({required this.endpointId});

  @override
  List<Object?> get props => [endpointId];
}

// Connection Management Events
class ConnectToDevice extends ConnectionEvent {
  final String endpointId;
  final ConnectionType? preferredType;

  const ConnectToDevice({required this.endpointId, this.preferredType});

  @override
  List<Object?> get props => [endpointId, preferredType];
}

class AcceptConnection extends ConnectionEvent {
  final String endpointId;

  const AcceptConnection({required this.endpointId});

  @override
  List<Object?> get props => [endpointId];
}

class RejectConnection extends ConnectionEvent {
  final String endpointId;
  final String? reason;

  const RejectConnection({required this.endpointId, this.reason});

  @override
  List<Object?> get props => [endpointId, reason];
}

class DisconnectFromDevice extends ConnectionEvent {
  final String? endpointId; // null means disconnect all

  const DisconnectFromDevice({this.endpointId});

  @override
  List<Object?> get props => [endpointId];
}

class ConnectionStatusUpdated extends ConnectionEvent {
  final String endpointId;
  final ConnectionStatus status;

  const ConnectionStatusUpdated({
    required this.endpointId,
    required this.status,
  });

  @override
  List<Object?> get props => [endpointId, status];
}

// QR Code Events
class GenerateQRCode extends ConnectionEvent {
  const GenerateQRCode();
}

class ConnectFromQRCode extends ConnectionEvent {
  final String qrData;

  const ConnectFromQRCode({required this.qrData});

  @override
  List<Object?> get props => [qrData];
}

// WiFi Hotspot Events
class EnableWiFiHotspot extends ConnectionEvent {
  const EnableWiFiHotspot();
}

class DisableWiFiHotspot extends ConnectionEvent {
  const DisableWiFiHotspot();
}

class CheckWiFiHotspotStatus extends ConnectionEvent {
  const CheckWiFiHotspotStatus();
}

// Permission Events
class RequestPermissions extends ConnectionEvent {
  const RequestPermissions();
}

class CheckPermissions extends ConnectionEvent {
  const CheckPermissions();
}
