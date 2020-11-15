import 'dart:async';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:pet_finder/import.dart';

part 'home.g.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this.repository)
      : assert(repository != null),
        super(HomeState());

  final DatabaseRepository repository;

  Future<void> load({String categoryId}) async {
    if (state.status == HomeStatus.loading) return;
    emit(state.copyWith(
      status: HomeStatus.loading,
    ));
    try {
      final categories = await repository.readCategories();
      final units =
          await repository.readNewestUnits(limit: kShowcaseNewestUnitsLimit);
      emit(HomeState());
      await Future.delayed(Duration(milliseconds: 300));
      emit(state.copyWith(
        categories: categories,
        units: units,
      ));
    } catch (error) {
      out('error');
      return Future.error(error);
    } finally {
      emit(state.copyWith(
        status: HomeStatus.ready,
      ));
    }
  }

  Future<String> search(String value) async {
    final searchInput = SearchInputModel.dirty(value);
    final status = Formz.validate([searchInput]);
    if (status.isInvalid) {
      return Future.error(ValidationException(searchInput.error));
    }
    return searchInput.value;
  }
}

enum HomeStatus { initial, loading, ready }

@CopyWith()
class HomeState extends Equatable {
  HomeState({
    this.categories = const [],
    this.units = const [],
    this.status = HomeStatus.initial,
  });

  final List<CategoryModel> categories;
  final List<UnitModel> units;
  final HomeStatus status;

  @override
  List<Object> get props => [
        categories,
        units,
        status,
      ];
}