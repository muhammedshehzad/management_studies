// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academic_records_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStudentDetailModelCollection on Isar {
  IsarCollection<StudentDetailModel> get studentDetailModels =>
      this.collection();
}

const StudentDetailModelSchema = CollectionSchema(
  name: r'StudentDetailModel',
  id: -6862122544362030489,
  properties: {
    r'academicYear': PropertySchema(
      id: 0,
      name: r'academicYear',
      type: IsarType.string,
    ),
    r'admissionDate': PropertySchema(
      id: 1,
      name: r'admissionDate',
      type: IsarType.dateTime,
    ),
    r'admissionNumber': PropertySchema(
      id: 2,
      name: r'admissionNumber',
      type: IsarType.string,
    ),
    r'department': PropertySchema(
      id: 3,
      name: r'department',
      type: IsarType.string,
    ),
    r'email': PropertySchema(
      id: 4,
      name: r'email',
      type: IsarType.string,
    ),
    r'fatherName': PropertySchema(
      id: 5,
      name: r'fatherName',
      type: IsarType.string,
    ),
    r'fatherOccupation': PropertySchema(
      id: 6,
      name: r'fatherOccupation',
      type: IsarType.string,
    ),
    r'fatherPhone': PropertySchema(
      id: 7,
      name: r'fatherPhone',
      type: IsarType.string,
    ),
    r'grade': PropertySchema(
      id: 8,
      name: r'grade',
      type: IsarType.string,
    ),
    r'hod': PropertySchema(
      id: 9,
      name: r'hod',
      type: IsarType.string,
    ),
    r'motherName': PropertySchema(
      id: 10,
      name: r'motherName',
      type: IsarType.string,
    ),
    r'motherOccupation': PropertySchema(
      id: 11,
      name: r'motherOccupation',
      type: IsarType.string,
    ),
    r'motherPhone': PropertySchema(
      id: 12,
      name: r'motherPhone',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 13,
      name: r'name',
      type: IsarType.string,
    ),
    r'percentage': PropertySchema(
      id: 14,
      name: r'percentage',
      type: IsarType.double,
    ),
    r'registerNumber': PropertySchema(
      id: 15,
      name: r'registerNumber',
      type: IsarType.string,
    ),
    r'score': PropertySchema(
      id: 16,
      name: r'score',
      type: IsarType.double,
    ),
    r'status': PropertySchema(
      id: 17,
      name: r'status',
      type: IsarType.string,
    ),
    r'uid': PropertySchema(
      id: 18,
      name: r'uid',
      type: IsarType.string,
    )
  },
  estimateSize: _studentDetailModelEstimateSize,
  serialize: _studentDetailModelSerialize,
  deserialize: _studentDetailModelDeserialize,
  deserializeProp: _studentDetailModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'uid': IndexSchema(
      id: 8193695471701937315,
      name: r'uid',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'uid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _studentDetailModelGetId,
  getLinks: _studentDetailModelGetLinks,
  attach: _studentDetailModelAttach,
  version: '3.1.0+1',
);

int _studentDetailModelEstimateSize(
  StudentDetailModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.academicYear.length * 3;
  bytesCount += 3 + object.admissionNumber.length * 3;
  bytesCount += 3 + object.department.length * 3;
  bytesCount += 3 + object.email.length * 3;
  bytesCount += 3 + object.fatherName.length * 3;
  bytesCount += 3 + object.fatherOccupation.length * 3;
  bytesCount += 3 + object.fatherPhone.length * 3;
  bytesCount += 3 + object.grade.length * 3;
  bytesCount += 3 + object.hod.length * 3;
  bytesCount += 3 + object.motherName.length * 3;
  bytesCount += 3 + object.motherOccupation.length * 3;
  bytesCount += 3 + object.motherPhone.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.registerNumber.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _studentDetailModelSerialize(
  StudentDetailModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.academicYear);
  writer.writeDateTime(offsets[1], object.admissionDate);
  writer.writeString(offsets[2], object.admissionNumber);
  writer.writeString(offsets[3], object.department);
  writer.writeString(offsets[4], object.email);
  writer.writeString(offsets[5], object.fatherName);
  writer.writeString(offsets[6], object.fatherOccupation);
  writer.writeString(offsets[7], object.fatherPhone);
  writer.writeString(offsets[8], object.grade);
  writer.writeString(offsets[9], object.hod);
  writer.writeString(offsets[10], object.motherName);
  writer.writeString(offsets[11], object.motherOccupation);
  writer.writeString(offsets[12], object.motherPhone);
  writer.writeString(offsets[13], object.name);
  writer.writeDouble(offsets[14], object.percentage);
  writer.writeString(offsets[15], object.registerNumber);
  writer.writeDouble(offsets[16], object.score);
  writer.writeString(offsets[17], object.status);
  writer.writeString(offsets[18], object.uid);
}

StudentDetailModel _studentDetailModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StudentDetailModel();
  object.academicYear = reader.readString(offsets[0]);
  object.admissionDate = reader.readDateTime(offsets[1]);
  object.admissionNumber = reader.readString(offsets[2]);
  object.department = reader.readString(offsets[3]);
  object.email = reader.readString(offsets[4]);
  object.fatherName = reader.readString(offsets[5]);
  object.fatherOccupation = reader.readString(offsets[6]);
  object.fatherPhone = reader.readString(offsets[7]);
  object.grade = reader.readString(offsets[8]);
  object.hod = reader.readString(offsets[9]);
  object.id = id;
  object.motherName = reader.readString(offsets[10]);
  object.motherOccupation = reader.readString(offsets[11]);
  object.motherPhone = reader.readString(offsets[12]);
  object.name = reader.readString(offsets[13]);
  object.percentage = reader.readDouble(offsets[14]);
  object.registerNumber = reader.readString(offsets[15]);
  object.score = reader.readDouble(offsets[16]);
  object.status = reader.readString(offsets[17]);
  object.uid = reader.readString(offsets[18]);
  return object;
}

P _studentDetailModelDeserializeProp<P>(
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
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readDouble(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readDouble(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _studentDetailModelGetId(StudentDetailModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _studentDetailModelGetLinks(
    StudentDetailModel object) {
  return [];
}

void _studentDetailModelAttach(
    IsarCollection<dynamic> col, Id id, StudentDetailModel object) {
  object.id = id;
}

extension StudentDetailModelByIndex on IsarCollection<StudentDetailModel> {
  Future<StudentDetailModel?> getByUid(String uid) {
    return getByIndex(r'uid', [uid]);
  }

  StudentDetailModel? getByUidSync(String uid) {
    return getByIndexSync(r'uid', [uid]);
  }

  Future<bool> deleteByUid(String uid) {
    return deleteByIndex(r'uid', [uid]);
  }

  bool deleteByUidSync(String uid) {
    return deleteByIndexSync(r'uid', [uid]);
  }

  Future<List<StudentDetailModel?>> getAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndex(r'uid', values);
  }

  List<StudentDetailModel?> getAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uid', values);
  }

  Future<int> deleteAllByUid(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uid', values);
  }

  int deleteAllByUidSync(List<String> uidValues) {
    final values = uidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uid', values);
  }

  Future<Id> putByUid(StudentDetailModel object) {
    return putByIndex(r'uid', object);
  }

  Id putByUidSync(StudentDetailModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'uid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUid(List<StudentDetailModel> objects) {
    return putAllByIndex(r'uid', objects);
  }

  List<Id> putAllByUidSync(List<StudentDetailModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uid', objects, saveLinks: saveLinks);
  }
}

extension StudentDetailModelQueryWhereSort
    on QueryBuilder<StudentDetailModel, StudentDetailModel, QWhere> {
  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension StudentDetailModelQueryWhere
    on QueryBuilder<StudentDetailModel, StudentDetailModel, QWhereClause> {
  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterWhereClause>
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

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterWhereClause>
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

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterWhereClause>
      uidEqualTo(String uid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uid',
        value: [uid],
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterWhereClause>
      uidNotEqualTo(String uid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [],
              upper: [uid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [uid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [uid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uid',
              lower: [],
              upper: [uid],
              includeUpper: false,
            ));
      }
    });
  }
}

extension StudentDetailModelQueryFilter
    on QueryBuilder<StudentDetailModel, StudentDetailModel, QFilterCondition> {
  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      academicYearEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'academicYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      academicYearGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'academicYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      academicYearLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'academicYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      academicYearBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'academicYear',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      academicYearStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'academicYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      academicYearEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'academicYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      academicYearContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'academicYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      academicYearMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'academicYear',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      academicYearIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'academicYear',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      academicYearIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'academicYear',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      admissionDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'admissionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      admissionDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'admissionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      admissionDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'admissionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      admissionDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'admissionDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      admissionNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'admissionNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      admissionNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'admissionNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      admissionNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'admissionNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      admissionNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'admissionNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      admissionNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'admissionNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      admissionNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'admissionNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      admissionNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'admissionNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      admissionNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'admissionNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      admissionNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'admissionNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      admissionNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'admissionNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      departmentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'department',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      departmentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'department',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      departmentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'department',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      departmentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'department',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      departmentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'department',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      departmentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'department',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      departmentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'department',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      departmentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'department',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      departmentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'department',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      departmentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'department',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      emailEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      emailGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      emailLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      emailBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'email',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      emailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      emailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      emailContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      emailMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'email',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      emailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      emailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatherName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fatherName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fatherName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fatherName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fatherName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fatherName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fatherName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fatherName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatherName',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fatherName',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherOccupationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatherOccupation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherOccupationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fatherOccupation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherOccupationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fatherOccupation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherOccupationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fatherOccupation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherOccupationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fatherOccupation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherOccupationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fatherOccupation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherOccupationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fatherOccupation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherOccupationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fatherOccupation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherOccupationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatherOccupation',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherOccupationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fatherOccupation',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherPhoneEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatherPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherPhoneGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fatherPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherPhoneLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fatherPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherPhoneBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fatherPhone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherPhoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fatherPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherPhoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fatherPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherPhoneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fatherPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherPhoneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fatherPhone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherPhoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatherPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      fatherPhoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fatherPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      gradeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      gradeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'grade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      gradeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'grade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      gradeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'grade',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      gradeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'grade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      gradeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'grade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      gradeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'grade',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      gradeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'grade',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      gradeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grade',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      gradeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'grade',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      hodEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      hodGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      hodLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      hodBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hod',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      hodStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      hodEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      hodContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hod',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      hodMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hod',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      hodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hod',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      hodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hod',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
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

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
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

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
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

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motherName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'motherName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'motherName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'motherName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'motherName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'motherName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'motherName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'motherName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motherName',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'motherName',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherOccupationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motherOccupation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherOccupationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'motherOccupation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherOccupationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'motherOccupation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherOccupationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'motherOccupation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherOccupationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'motherOccupation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherOccupationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'motherOccupation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherOccupationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'motherOccupation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherOccupationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'motherOccupation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherOccupationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motherOccupation',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherOccupationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'motherOccupation',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherPhoneEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motherPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherPhoneGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'motherPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherPhoneLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'motherPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherPhoneBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'motherPhone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherPhoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'motherPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherPhoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'motherPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherPhoneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'motherPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherPhoneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'motherPhone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherPhoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motherPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      motherPhoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'motherPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      percentageEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'percentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      percentageGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'percentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      percentageLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'percentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      percentageBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'percentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      registerNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'registerNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      registerNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'registerNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      registerNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'registerNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      registerNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'registerNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      registerNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'registerNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      registerNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'registerNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      registerNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'registerNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      registerNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'registerNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      registerNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'registerNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      registerNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'registerNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      scoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'score',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      scoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'score',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      scoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'score',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      scoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'score',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
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

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
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

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
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

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
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

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
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

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
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

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      uidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      uidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterFilterCondition>
      uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }
}

extension StudentDetailModelQueryObject
    on QueryBuilder<StudentDetailModel, StudentDetailModel, QFilterCondition> {}

extension StudentDetailModelQueryLinks
    on QueryBuilder<StudentDetailModel, StudentDetailModel, QFilterCondition> {}

extension StudentDetailModelQuerySortBy
    on QueryBuilder<StudentDetailModel, StudentDetailModel, QSortBy> {
  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByAcademicYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYear', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByAcademicYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYear', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByAdmissionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'admissionDate', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByAdmissionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'admissionDate', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByAdmissionNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'admissionNumber', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByAdmissionNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'admissionNumber', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByDepartment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'department', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByDepartmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'department', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByFatherName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatherName', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByFatherNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatherName', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByFatherOccupation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatherOccupation', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByFatherOccupationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatherOccupation', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByFatherPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatherPhone', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByFatherPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatherPhone', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByGrade() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grade', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByGradeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grade', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByHod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hod', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByHodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hod', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByMotherName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motherName', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByMotherNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motherName', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByMotherOccupation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motherOccupation', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByMotherOccupationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motherOccupation', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByMotherPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motherPhone', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByMotherPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motherPhone', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'percentage', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'percentage', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByRegisterNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'registerNumber', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByRegisterNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'registerNumber', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension StudentDetailModelQuerySortThenBy
    on QueryBuilder<StudentDetailModel, StudentDetailModel, QSortThenBy> {
  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByAcademicYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYear', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByAcademicYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'academicYear', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByAdmissionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'admissionDate', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByAdmissionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'admissionDate', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByAdmissionNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'admissionNumber', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByAdmissionNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'admissionNumber', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByDepartment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'department', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByDepartmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'department', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByFatherName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatherName', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByFatherNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatherName', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByFatherOccupation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatherOccupation', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByFatherOccupationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatherOccupation', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByFatherPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatherPhone', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByFatherPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatherPhone', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByGrade() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grade', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByGradeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grade', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByHod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hod', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByHodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hod', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByMotherName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motherName', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByMotherNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motherName', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByMotherOccupation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motherOccupation', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByMotherOccupationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motherOccupation', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByMotherPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motherPhone', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByMotherPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motherPhone', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'percentage', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'percentage', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByRegisterNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'registerNumber', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByRegisterNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'registerNumber', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QAfterSortBy>
      thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }
}

extension StudentDetailModelQueryWhereDistinct
    on QueryBuilder<StudentDetailModel, StudentDetailModel, QDistinct> {
  QueryBuilder<StudentDetailModel, StudentDetailModel, QDistinct>
      distinctByAcademicYear({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'academicYear', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QDistinct>
      distinctByAdmissionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'admissionDate');
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QDistinct>
      distinctByAdmissionNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'admissionNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QDistinct>
      distinctByDepartment({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'department', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QDistinct>
      distinctByEmail({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'email', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QDistinct>
      distinctByFatherName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fatherName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QDistinct>
      distinctByFatherOccupation({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fatherOccupation',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QDistinct>
      distinctByFatherPhone({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fatherPhone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QDistinct>
      distinctByGrade({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'grade', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QDistinct> distinctByHod(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hod', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QDistinct>
      distinctByMotherName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'motherName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QDistinct>
      distinctByMotherOccupation({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'motherOccupation',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QDistinct>
      distinctByMotherPhone({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'motherPhone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QDistinct>
      distinctByName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QDistinct>
      distinctByPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'percentage');
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QDistinct>
      distinctByRegisterNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'registerNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QDistinct>
      distinctByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'score');
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StudentDetailModel, StudentDetailModel, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }
}

extension StudentDetailModelQueryProperty
    on QueryBuilder<StudentDetailModel, StudentDetailModel, QQueryProperty> {
  QueryBuilder<StudentDetailModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StudentDetailModel, String, QQueryOperations>
      academicYearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'academicYear');
    });
  }

  QueryBuilder<StudentDetailModel, DateTime, QQueryOperations>
      admissionDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'admissionDate');
    });
  }

  QueryBuilder<StudentDetailModel, String, QQueryOperations>
      admissionNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'admissionNumber');
    });
  }

  QueryBuilder<StudentDetailModel, String, QQueryOperations>
      departmentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'department');
    });
  }

  QueryBuilder<StudentDetailModel, String, QQueryOperations> emailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'email');
    });
  }

  QueryBuilder<StudentDetailModel, String, QQueryOperations>
      fatherNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fatherName');
    });
  }

  QueryBuilder<StudentDetailModel, String, QQueryOperations>
      fatherOccupationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fatherOccupation');
    });
  }

  QueryBuilder<StudentDetailModel, String, QQueryOperations>
      fatherPhoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fatherPhone');
    });
  }

  QueryBuilder<StudentDetailModel, String, QQueryOperations> gradeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'grade');
    });
  }

  QueryBuilder<StudentDetailModel, String, QQueryOperations> hodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hod');
    });
  }

  QueryBuilder<StudentDetailModel, String, QQueryOperations>
      motherNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'motherName');
    });
  }

  QueryBuilder<StudentDetailModel, String, QQueryOperations>
      motherOccupationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'motherOccupation');
    });
  }

  QueryBuilder<StudentDetailModel, String, QQueryOperations>
      motherPhoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'motherPhone');
    });
  }

  QueryBuilder<StudentDetailModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<StudentDetailModel, double, QQueryOperations>
      percentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'percentage');
    });
  }

  QueryBuilder<StudentDetailModel, String, QQueryOperations>
      registerNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'registerNumber');
    });
  }

  QueryBuilder<StudentDetailModel, double, QQueryOperations> scoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'score');
    });
  }

  QueryBuilder<StudentDetailModel, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<StudentDetailModel, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }
}
