// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homework_records_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHomeworkRecordModelCollection on Isar {
  IsarCollection<HomeworkRecordModel> get homeworkRecordModels =>
      this.collection();
}

const HomeworkRecordModelSchema = CollectionSchema(
  name: r'HomeworkRecordModel',
  id: 4175578772780753875,
  properties: {
    r'assignedBy': PropertySchema(
      id: 0,
      name: r'assignedBy',
      type: IsarType.string,
    ),
    r'deadline': PropertySchema(
      id: 1,
      name: r'deadline',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 2,
      name: r'description',
      type: IsarType.string,
    ),
    r'docid': PropertySchema(
      id: 3,
      name: r'docid',
      type: IsarType.string,
    ),
    r'estimatedTime': PropertySchema(
      id: 4,
      name: r'estimatedTime',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 5,
      name: r'status',
      type: IsarType.string,
    ),
    r'subject': PropertySchema(
      id: 6,
      name: r'subject',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 7,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _homeworkRecordModelEstimateSize,
  serialize: _homeworkRecordModelSerialize,
  deserialize: _homeworkRecordModelDeserialize,
  deserializeProp: _homeworkRecordModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'docid': IndexSchema(
      id: 1049794645742842999,
      name: r'docid',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'docid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _homeworkRecordModelGetId,
  getLinks: _homeworkRecordModelGetLinks,
  attach: _homeworkRecordModelAttach,
  version: '3.1.0+1',
);

int _homeworkRecordModelEstimateSize(
  HomeworkRecordModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.assignedBy.length * 3;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.docid.length * 3;
  bytesCount += 3 + object.estimatedTime.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.subject.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _homeworkRecordModelSerialize(
  HomeworkRecordModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.assignedBy);
  writer.writeDateTime(offsets[1], object.deadline);
  writer.writeString(offsets[2], object.description);
  writer.writeString(offsets[3], object.docid);
  writer.writeString(offsets[4], object.estimatedTime);
  writer.writeString(offsets[5], object.status);
  writer.writeString(offsets[6], object.subject);
  writer.writeString(offsets[7], object.title);
}

HomeworkRecordModel _homeworkRecordModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HomeworkRecordModel();
  object.assignedBy = reader.readString(offsets[0]);
  object.deadline = reader.readDateTime(offsets[1]);
  object.description = reader.readString(offsets[2]);
  object.docid = reader.readString(offsets[3]);
  object.estimatedTime = reader.readString(offsets[4]);
  object.id = id;
  object.status = reader.readString(offsets[5]);
  object.subject = reader.readString(offsets[6]);
  object.title = reader.readString(offsets[7]);
  return object;
}

P _homeworkRecordModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _homeworkRecordModelGetId(HomeworkRecordModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _homeworkRecordModelGetLinks(
    HomeworkRecordModel object) {
  return [];
}

void _homeworkRecordModelAttach(
    IsarCollection<dynamic> col, Id id, HomeworkRecordModel object) {
  object.id = id;
}

extension HomeworkRecordModelByIndex on IsarCollection<HomeworkRecordModel> {
  Future<HomeworkRecordModel?> getByDocid(String docid) {
    return getByIndex(r'docid', [docid]);
  }

  HomeworkRecordModel? getByDocidSync(String docid) {
    return getByIndexSync(r'docid', [docid]);
  }

  Future<bool> deleteByDocid(String docid) {
    return deleteByIndex(r'docid', [docid]);
  }

  bool deleteByDocidSync(String docid) {
    return deleteByIndexSync(r'docid', [docid]);
  }

  Future<List<HomeworkRecordModel?>> getAllByDocid(List<String> docidValues) {
    final values = docidValues.map((e) => [e]).toList();
    return getAllByIndex(r'docid', values);
  }

  List<HomeworkRecordModel?> getAllByDocidSync(List<String> docidValues) {
    final values = docidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'docid', values);
  }

  Future<int> deleteAllByDocid(List<String> docidValues) {
    final values = docidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'docid', values);
  }

  int deleteAllByDocidSync(List<String> docidValues) {
    final values = docidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'docid', values);
  }

  Future<Id> putByDocid(HomeworkRecordModel object) {
    return putByIndex(r'docid', object);
  }

  Id putByDocidSync(HomeworkRecordModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'docid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDocid(List<HomeworkRecordModel> objects) {
    return putAllByIndex(r'docid', objects);
  }

  List<Id> putAllByDocidSync(List<HomeworkRecordModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'docid', objects, saveLinks: saveLinks);
  }
}

extension HomeworkRecordModelQueryWhereSort
    on QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QWhere> {
  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension HomeworkRecordModelQueryWhere
    on QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QWhereClause> {
  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterWhereClause>
      docidEqualTo(String docid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'docid',
        value: [docid],
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterWhereClause>
      docidNotEqualTo(String docid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'docid',
              lower: [],
              upper: [docid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'docid',
              lower: [docid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'docid',
              lower: [docid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'docid',
              lower: [],
              upper: [docid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension HomeworkRecordModelQueryFilter on QueryBuilder<HomeworkRecordModel,
    HomeworkRecordModel, QFilterCondition> {
  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      assignedByEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      assignedByGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'assignedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      assignedByLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'assignedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      assignedByBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'assignedBy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      assignedByStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'assignedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      assignedByEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'assignedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      assignedByContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'assignedBy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      assignedByMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'assignedBy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      assignedByIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'assignedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      assignedByIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'assignedBy',
        value: '',
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      deadlineEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deadline',
        value: value,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      deadlineGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deadline',
        value: value,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      deadlineLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deadline',
        value: value,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      deadlineBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deadline',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      docidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'docid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      docidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'docid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      docidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'docid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      docidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'docid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      docidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'docid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      docidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'docid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      docidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'docid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      docidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'docid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      docidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'docid',
        value: '',
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      docidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'docid',
        value: '',
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      estimatedTimeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estimatedTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      estimatedTimeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'estimatedTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      estimatedTimeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'estimatedTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      estimatedTimeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'estimatedTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      estimatedTimeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'estimatedTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      estimatedTimeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'estimatedTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      estimatedTimeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'estimatedTime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      estimatedTimeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'estimatedTime',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      estimatedTimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estimatedTime',
        value: '',
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      estimatedTimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'estimatedTime',
        value: '',
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
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

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      subjectEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      subjectGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      subjectLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      subjectBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subject',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      subjectStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      subjectEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      subjectContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      subjectMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subject',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      subjectIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subject',
        value: '',
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      subjectIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subject',
        value: '',
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension HomeworkRecordModelQueryObject on QueryBuilder<HomeworkRecordModel,
    HomeworkRecordModel, QFilterCondition> {}

extension HomeworkRecordModelQueryLinks on QueryBuilder<HomeworkRecordModel,
    HomeworkRecordModel, QFilterCondition> {}

extension HomeworkRecordModelQuerySortBy
    on QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QSortBy> {
  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      sortByAssignedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBy', Sort.asc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      sortByAssignedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBy', Sort.desc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      sortByDeadline() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadline', Sort.asc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      sortByDeadlineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadline', Sort.desc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      sortByDocid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'docid', Sort.asc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      sortByDocidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'docid', Sort.desc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      sortByEstimatedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedTime', Sort.asc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      sortByEstimatedTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedTime', Sort.desc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      sortBySubject() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.asc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      sortBySubjectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.desc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension HomeworkRecordModelQuerySortThenBy
    on QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QSortThenBy> {
  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      thenByAssignedBy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBy', Sort.asc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      thenByAssignedByDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'assignedBy', Sort.desc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      thenByDeadline() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadline', Sort.asc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      thenByDeadlineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deadline', Sort.desc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      thenByDocid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'docid', Sort.asc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      thenByDocidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'docid', Sort.desc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      thenByEstimatedTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedTime', Sort.asc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      thenByEstimatedTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedTime', Sort.desc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      thenBySubject() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.asc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      thenBySubjectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.desc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension HomeworkRecordModelQueryWhereDistinct
    on QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QDistinct> {
  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QDistinct>
      distinctByAssignedBy({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'assignedBy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QDistinct>
      distinctByDeadline() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deadline');
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QDistinct>
      distinctByDocid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'docid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QDistinct>
      distinctByEstimatedTime({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estimatedTime',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QDistinct>
      distinctBySubject({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subject', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension HomeworkRecordModelQueryProperty
    on QueryBuilder<HomeworkRecordModel, HomeworkRecordModel, QQueryProperty> {
  QueryBuilder<HomeworkRecordModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<HomeworkRecordModel, String, QQueryOperations>
      assignedByProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'assignedBy');
    });
  }

  QueryBuilder<HomeworkRecordModel, DateTime, QQueryOperations>
      deadlineProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deadline');
    });
  }

  QueryBuilder<HomeworkRecordModel, String, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<HomeworkRecordModel, String, QQueryOperations> docidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'docid');
    });
  }

  QueryBuilder<HomeworkRecordModel, String, QQueryOperations>
      estimatedTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estimatedTime');
    });
  }

  QueryBuilder<HomeworkRecordModel, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<HomeworkRecordModel, String, QQueryOperations>
      subjectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subject');
    });
  }

  QueryBuilder<HomeworkRecordModel, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
