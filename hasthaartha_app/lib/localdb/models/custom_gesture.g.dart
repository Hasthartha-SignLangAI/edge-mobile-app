// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_gesture.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCustomGestureCollection on Isar {
  IsarCollection<CustomGesture> get customGestures => this.collection();
}

const CustomGestureSchema = CollectionSchema(
  name: r'CustomGesture',
  id: 7095443060850104453,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'label': PropertySchema(
      id: 1,
      name: r'label',
      type: IsarType.string,
    ),
    r'prototype': PropertySchema(
      id: 2,
      name: r'prototype',
      type: IsarType.doubleList,
    ),
    r'sampleCount': PropertySchema(
      id: 3,
      name: r'sampleCount',
      type: IsarType.long,
    ),
    r'userId': PropertySchema(
      id: 4,
      name: r'userId',
      type: IsarType.string,
    )
  },
  estimateSize: _customGestureEstimateSize,
  serialize: _customGestureSerialize,
  deserialize: _customGestureDeserialize,
  deserializeProp: _customGestureDeserializeProp,
  idName: r'id',
  indexes: {
    r'userId': IndexSchema(
      id: -2005826577402374815,
      name: r'userId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'label_userId': IndexSchema(
      id: -5558357408917693753,
      name: r'label_userId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'label',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _customGestureGetId,
  getLinks: _customGestureGetLinks,
  attach: _customGestureAttach,
  version: '3.1.0+1',
);

int _customGestureEstimateSize(
  CustomGesture object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.label.length * 3;
  bytesCount += 3 + object.prototype.length * 8;
  bytesCount += 3 + object.userId.length * 3;
  return bytesCount;
}

void _customGestureSerialize(
  CustomGesture object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.label);
  writer.writeDoubleList(offsets[2], object.prototype);
  writer.writeLong(offsets[3], object.sampleCount);
  writer.writeString(offsets[4], object.userId);
}

CustomGesture _customGestureDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CustomGesture();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.label = reader.readString(offsets[1]);
  object.prototype = reader.readDoubleList(offsets[2]) ?? [];
  object.sampleCount = reader.readLong(offsets[3]);
  object.userId = reader.readString(offsets[4]);
  return object;
}

P _customGestureDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDoubleList(offset) ?? []) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _customGestureGetId(CustomGesture object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _customGestureGetLinks(CustomGesture object) {
  return [];
}

void _customGestureAttach(
    IsarCollection<dynamic> col, Id id, CustomGesture object) {
  object.id = id;
}

extension CustomGestureByIndex on IsarCollection<CustomGesture> {
  Future<CustomGesture?> getByLabelUserId(String label, String userId) {
    return getByIndex(r'label_userId', [label, userId]);
  }

  CustomGesture? getByLabelUserIdSync(String label, String userId) {
    return getByIndexSync(r'label_userId', [label, userId]);
  }

  Future<bool> deleteByLabelUserId(String label, String userId) {
    return deleteByIndex(r'label_userId', [label, userId]);
  }

  bool deleteByLabelUserIdSync(String label, String userId) {
    return deleteByIndexSync(r'label_userId', [label, userId]);
  }

  Future<List<CustomGesture?>> getAllByLabelUserId(
      List<String> labelValues, List<String> userIdValues) {
    final len = labelValues.length;
    assert(userIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([labelValues[i], userIdValues[i]]);
    }

    return getAllByIndex(r'label_userId', values);
  }

  List<CustomGesture?> getAllByLabelUserIdSync(
      List<String> labelValues, List<String> userIdValues) {
    final len = labelValues.length;
    assert(userIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([labelValues[i], userIdValues[i]]);
    }

    return getAllByIndexSync(r'label_userId', values);
  }

  Future<int> deleteAllByLabelUserId(
      List<String> labelValues, List<String> userIdValues) {
    final len = labelValues.length;
    assert(userIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([labelValues[i], userIdValues[i]]);
    }

    return deleteAllByIndex(r'label_userId', values);
  }

  int deleteAllByLabelUserIdSync(
      List<String> labelValues, List<String> userIdValues) {
    final len = labelValues.length;
    assert(userIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([labelValues[i], userIdValues[i]]);
    }

    return deleteAllByIndexSync(r'label_userId', values);
  }

  Future<Id> putByLabelUserId(CustomGesture object) {
    return putByIndex(r'label_userId', object);
  }

  Id putByLabelUserIdSync(CustomGesture object, {bool saveLinks = true}) {
    return putByIndexSync(r'label_userId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByLabelUserId(List<CustomGesture> objects) {
    return putAllByIndex(r'label_userId', objects);
  }

  List<Id> putAllByLabelUserIdSync(List<CustomGesture> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'label_userId', objects, saveLinks: saveLinks);
  }
}

extension CustomGestureQueryWhereSort
    on QueryBuilder<CustomGesture, CustomGesture, QWhere> {
  QueryBuilder<CustomGesture, CustomGesture, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CustomGestureQueryWhere
    on QueryBuilder<CustomGesture, CustomGesture, QWhereClause> {
  QueryBuilder<CustomGesture, CustomGesture, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterWhereClause> userIdEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterWhereClause>
      userIdNotEqualTo(String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [userId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'userId',
              lower: [],
              upper: [userId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterWhereClause>
      labelEqualToAnyUserId(String label) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'label_userId',
        value: [label],
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterWhereClause>
      labelNotEqualToAnyUserId(String label) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'label_userId',
              lower: [],
              upper: [label],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'label_userId',
              lower: [label],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'label_userId',
              lower: [label],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'label_userId',
              lower: [],
              upper: [label],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterWhereClause>
      labelUserIdEqualTo(String label, String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'label_userId',
        value: [label, userId],
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterWhereClause>
      labelEqualToUserIdNotEqualTo(String label, String userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'label_userId',
              lower: [label],
              upper: [label, userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'label_userId',
              lower: [label, userId],
              includeLower: false,
              upper: [label],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'label_userId',
              lower: [label, userId],
              includeLower: false,
              upper: [label],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'label_userId',
              lower: [label],
              upper: [label, userId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CustomGestureQueryFilter
    on QueryBuilder<CustomGesture, CustomGesture, QFilterCondition> {
  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      labelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      labelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      labelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      labelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'label',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      labelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      labelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      labelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      labelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'label',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      prototypeElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'prototype',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      prototypeElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'prototype',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      prototypeElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'prototype',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      prototypeElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'prototype',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      prototypeLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'prototype',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      prototypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'prototype',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      prototypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'prototype',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      prototypeLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'prototype',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      prototypeLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'prototype',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      prototypeLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'prototype',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      sampleCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sampleCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      sampleCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sampleCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      sampleCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sampleCount',
        value: value,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      sampleCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sampleCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      userIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      userIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      userIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      userIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      userIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      userIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      userIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }
}

extension CustomGestureQueryObject
    on QueryBuilder<CustomGesture, CustomGesture, QFilterCondition> {}

extension CustomGestureQueryLinks
    on QueryBuilder<CustomGesture, CustomGesture, QFilterCondition> {}

extension CustomGestureQuerySortBy
    on QueryBuilder<CustomGesture, CustomGesture, QSortBy> {
  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> sortByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> sortByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> sortBySampleCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleCount', Sort.asc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy>
      sortBySampleCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleCount', Sort.desc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension CustomGestureQuerySortThenBy
    on QueryBuilder<CustomGesture, CustomGesture, QSortThenBy> {
  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> thenByLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.asc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> thenByLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'label', Sort.desc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> thenBySampleCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleCount', Sort.asc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy>
      thenBySampleCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sampleCount', Sort.desc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension CustomGestureQueryWhereDistinct
    on QueryBuilder<CustomGesture, CustomGesture, QDistinct> {
  QueryBuilder<CustomGesture, CustomGesture, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QDistinct> distinctByLabel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'label', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QDistinct> distinctByPrototype() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'prototype');
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QDistinct>
      distinctBySampleCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sampleCount');
    });
  }

  QueryBuilder<CustomGesture, CustomGesture, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }
}

extension CustomGestureQueryProperty
    on QueryBuilder<CustomGesture, CustomGesture, QQueryProperty> {
  QueryBuilder<CustomGesture, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CustomGesture, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CustomGesture, String, QQueryOperations> labelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'label');
    });
  }

  QueryBuilder<CustomGesture, List<double>, QQueryOperations>
      prototypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'prototype');
    });
  }

  QueryBuilder<CustomGesture, int, QQueryOperations> sampleCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sampleCount');
    });
  }

  QueryBuilder<CustomGesture, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
