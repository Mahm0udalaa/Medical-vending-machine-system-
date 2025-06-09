import 'package:equatable/equatable.dart';

abstract class ProfileUpdateState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileUpdateInitial extends ProfileUpdateState {}

class ProfileUpdateLoading extends ProfileUpdateState {}

class ProfileUpdateSuccess extends ProfileUpdateState {}

class ProfileUpdateError extends ProfileUpdateState {
  final String message;
  ProfileUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileUpdateWithImage extends ProfileUpdateState {
  final String imagePath;

  ProfileUpdateWithImage(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}
