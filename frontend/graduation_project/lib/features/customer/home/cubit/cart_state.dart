part of 'cart_cubit.dart';

abstract class CartState {}

class CartInitial extends CartState {}
class CartLoading extends CartState {}
class CartSuccess extends CartState {
  final Map<String, dynamic> data;
  CartSuccess(this.data);
}
class CartError extends CartState {
  final String message;
  final Map<String, dynamic>? data;
  CartError(this.message, this.data);
} 