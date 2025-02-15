// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school_details_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSchoolDetailsCollection on Isar {
  IsarCollection<SchoolDetails> get schoolDetails => this.collection();
}

const SchoolDetailsSchema = CollectionSchema(
  name: r'SchoolDetails',
  id: 7066879081062600784,
  properties: {
    r'schoolContact': PropertySchema(
      id: 0,
      name: r'schoolContact',
      type: IsarType.string,
    ),
    r'schoolImageUrl': PropertySchema(
      id: 1,
      name: r'schoolImageUrl',
      type: IsarType.string,
    ),
    r'schoolLocation': PropertySchema(
      id: 2,
      name: r'schoolLocation',
      type: IsarType.string,
    ),
    r'schoolName': PropertySchema(
      id: 3,
      name: r'schoolName',
      type: IsarType.string,
    ),
    r'schoolType': PropertySchema(
      id: 4,
      name: r'schoolType',
      type: IsarType.string,
    ),
    r'schoolWebsite': PropertySchema(
      id: 5,
      name: r'schoolWebsite',
      type: IsarType.string,
    )
  },
  estimateSize: _schoolDetailsEstimateSize,
  serialize: _schoolDetailsSerialize,
  deserialize: _schoolDetailsDeserialize,
  deserializeProp: _schoolDetailsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _schoolDetailsGetId,
  getLinks: _schoolDetailsGetLinks,
  attach: _schoolDetailsAttach,
  version: '3.1.0+1',
);

int _schoolDetailsEstimateSize(
  SchoolDetails object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.schoolContact.length * 3;
  {
    final value = object.schoolImageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.schoolLocation.length * 3;
  bytesCount += 3 + object.schoolName.length * 3;
  bytesCount += 3 + object.schoolType.length * 3;
  bytesCount += 3 + object.schoolWebsite.length * 3;
  return bytesCount;
}

void _schoolDetailsSerialize(
  SchoolDetails object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.schoolContact);
  writer.writeString(offsets[1], object.schoolImageUrl);
  writer.writeString(offsets[2], object.schoolLocation);
  writer.writeString(offsets[3], object.schoolName);
  writer.writeString(offsets[4], object.schoolType);
  writer.writeString(offsets[5], object.schoolWebsite);
}

SchoolDetails _schoolDetailsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SchoolDetails();
  object.id = id;
  object.schoolContact = reader.readString(offsets[0]);
  object.schoolImageUrl = reader.readStringOrNull(offsets[1]);
  object.schoolLocation = reader.readString(offsets[2]);
  object.schoolName = reader.readString(offsets[3]);
  object.schoolType = reader.readString(offsets[4]);
  object.schoolWebsite = reader.readString(offsets[5]);
  return object;
}

P _schoolDetailsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _schoolDetailsGetId(SchoolDetails object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _schoolDetailsGetLinks(SchoolDetails object) {
  return [];
}

void _schoolDetailsAttach(
    IsarCollection<dynamic> col, Id id, SchoolDetails object) {
  object.id = id;
}

extension SchoolDetailsQueryWhereSort
    on QueryBuilder<SchoolDetails, SchoolDetails, QWhere> {
  QueryBuilder<SchoolDetails, SchoolDetails, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SchoolDetailsQueryWhere
    on QueryBuilder<SchoolDetails, SchoolDetails, QWhereClause> {
  QueryBuilder<SchoolDetails, SchoolDetails, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterWhereClause> idBetween(
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
}

extension SchoolDetailsQueryFilter
    on QueryBuilder<SchoolDetails, SchoolDetails, QFilterCondition> {
  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
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

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolContactEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolContact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolContactGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'schoolContact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolContactLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'schoolContact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolContactBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'schoolContact',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolContactStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'schoolContact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolContactEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'schoolContact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolContactContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolContact',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolContactMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolContact',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolContactIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolContact',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolContactIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolContact',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolImageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'schoolImageUrl',
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolImageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'schoolImageUrl',
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolImageUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolImageUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'schoolImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolImageUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'schoolImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolImageUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'schoolImageUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolImageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'schoolImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolImageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'schoolImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolImageUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolImageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolImageUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolImageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolImageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolImageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolImageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolImageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolLocationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolLocationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'schoolLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolLocationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'schoolLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolLocationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'schoolLocation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolLocationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'schoolLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolLocationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'schoolLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolLocationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolLocationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolLocation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolLocationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolLocation',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolLocationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolLocation',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'schoolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'schoolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'schoolName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'schoolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'schoolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolName',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolName',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'schoolType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'schoolType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'schoolType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'schoolType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'schoolType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolType',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolType',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolWebsiteEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolWebsite',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolWebsiteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'schoolWebsite',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolWebsiteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'schoolWebsite',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolWebsiteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'schoolWebsite',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolWebsiteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'schoolWebsite',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolWebsiteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'schoolWebsite',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolWebsiteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'schoolWebsite',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolWebsiteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'schoolWebsite',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolWebsiteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schoolWebsite',
        value: '',
      ));
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterFilterCondition>
      schoolWebsiteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'schoolWebsite',
        value: '',
      ));
    });
  }
}

extension SchoolDetailsQueryObject
    on QueryBuilder<SchoolDetails, SchoolDetails, QFilterCondition> {}

extension SchoolDetailsQueryLinks
    on QueryBuilder<SchoolDetails, SchoolDetails, QFilterCondition> {}

extension SchoolDetailsQuerySortBy
    on QueryBuilder<SchoolDetails, SchoolDetails, QSortBy> {
  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy>
      sortBySchoolContact() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolContact', Sort.asc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy>
      sortBySchoolContactDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolContact', Sort.desc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy>
      sortBySchoolImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolImageUrl', Sort.asc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy>
      sortBySchoolImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolImageUrl', Sort.desc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy>
      sortBySchoolLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolLocation', Sort.asc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy>
      sortBySchoolLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolLocation', Sort.desc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy> sortBySchoolName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolName', Sort.asc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy>
      sortBySchoolNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolName', Sort.desc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy> sortBySchoolType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolType', Sort.asc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy>
      sortBySchoolTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolType', Sort.desc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy>
      sortBySchoolWebsite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolWebsite', Sort.asc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy>
      sortBySchoolWebsiteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolWebsite', Sort.desc);
    });
  }
}

extension SchoolDetailsQuerySortThenBy
    on QueryBuilder<SchoolDetails, SchoolDetails, QSortThenBy> {
  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy>
      thenBySchoolContact() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolContact', Sort.asc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy>
      thenBySchoolContactDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolContact', Sort.desc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy>
      thenBySchoolImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolImageUrl', Sort.asc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy>
      thenBySchoolImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolImageUrl', Sort.desc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy>
      thenBySchoolLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolLocation', Sort.asc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy>
      thenBySchoolLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolLocation', Sort.desc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy> thenBySchoolName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolName', Sort.asc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy>
      thenBySchoolNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolName', Sort.desc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy> thenBySchoolType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolType', Sort.asc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy>
      thenBySchoolTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolType', Sort.desc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy>
      thenBySchoolWebsite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolWebsite', Sort.asc);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QAfterSortBy>
      thenBySchoolWebsiteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schoolWebsite', Sort.desc);
    });
  }
}

extension SchoolDetailsQueryWhereDistinct
    on QueryBuilder<SchoolDetails, SchoolDetails, QDistinct> {
  QueryBuilder<SchoolDetails, SchoolDetails, QDistinct> distinctBySchoolContact(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolContact',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QDistinct>
      distinctBySchoolImageUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolImageUrl',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QDistinct>
      distinctBySchoolLocation({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolLocation',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QDistinct> distinctBySchoolName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QDistinct> distinctBySchoolType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SchoolDetails, SchoolDetails, QDistinct> distinctBySchoolWebsite(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schoolWebsite',
          caseSensitive: caseSensitive);
    });
  }
}

extension SchoolDetailsQueryProperty
    on QueryBuilder<SchoolDetails, SchoolDetails, QQueryProperty> {
  QueryBuilder<SchoolDetails, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SchoolDetails, String, QQueryOperations>
      schoolContactProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolContact');
    });
  }

  QueryBuilder<SchoolDetails, String?, QQueryOperations>
      schoolImageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolImageUrl');
    });
  }

  QueryBuilder<SchoolDetails, String, QQueryOperations>
      schoolLocationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolLocation');
    });
  }

  QueryBuilder<SchoolDetails, String, QQueryOperations> schoolNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolName');
    });
  }

  QueryBuilder<SchoolDetails, String, QQueryOperations> schoolTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolType');
    });
  }

  QueryBuilder<SchoolDetails, String, QQueryOperations>
      schoolWebsiteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schoolWebsite');
    });
  }
}
