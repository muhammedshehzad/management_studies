// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_request_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLeaveRequestCollection on Isar {
  IsarCollection<LeaveRequest> get leaveRequests => this.collection();
}

const LeaveRequestSchema = CollectionSchema(
  name: r'LeaveRequest',
  id: 5503567001840078282,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'creatorRole': PropertySchema(
      id: 1,
      name: r'creatorRole',
      type: IsarType.string,
    ),
    r'durationDays': PropertySchema(
      id: 2,
      name: r'durationDays',
      type: IsarType.long,
    ),
    r'endDate': PropertySchema(
      id: 3,
      name: r'endDate',
      type: IsarType.dateTime,
    ),
    r'isSynced': PropertySchema(
      id: 4,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'leaveReason': PropertySchema(
      id: 5,
      name: r'leaveReason',
      type: IsarType.string,
    ),
    r'leaveType': PropertySchema(
      id: 6,
      name: r'leaveType',
      type: IsarType.string,
    ),
    r'leavesId': PropertySchema(
      id: 7,
      name: r'leavesId',
      type: IsarType.string,
    ),
    r'notificationSent': PropertySchema(
      id: 8,
      name: r'notificationSent',
      type: IsarType.bool,
    ),
    r'pendingSync': PropertySchema(
      id: 9,
      name: r'pendingSync',
      type: IsarType.bool,
    ),
    r'startDate': PropertySchema(
      id: 10,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(
      id: 11,
      name: r'status',
      type: IsarType.string,
    ),
    r'userDepartment': PropertySchema(
      id: 12,
      name: r'userDepartment',
      type: IsarType.string,
    ),
    r'userId': PropertySchema(
      id: 13,
      name: r'userId',
      type: IsarType.string,
    ),
    r'username': PropertySchema(
      id: 14,
      name: r'username',
      type: IsarType.string,
    )
  },
  estimateSize: _leaveRequestEstimateSize,
  serialize: _leaveRequestSerialize,
  deserialize: _leaveRequestDeserialize,
  deserializeProp: _leaveRequestDeserializeProp,
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
    r'leavesId': IndexSchema(
      id: 7863350640034441536,
      name: r'leavesId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'leavesId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _leaveRequestGetId,
  getLinks: _leaveRequestGetLinks,
  attach: _leaveRequestAttach,
  version: '3.1.0+1',
);

int _leaveRequestEstimateSize(
  LeaveRequest object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.creatorRole.length * 3;
  bytesCount += 3 + object.leaveReason.length * 3;
  bytesCount += 3 + object.leaveType.length * 3;
  bytesCount += 3 + object.leavesId.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.userDepartment.length * 3;
  bytesCount += 3 + object.userId.length * 3;
  bytesCount += 3 + object.username.length * 3;
  return bytesCount;
}

void _leaveRequestSerialize(
  LeaveRequest object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.creatorRole);
  writer.writeLong(offsets[2], object.durationDays);
  writer.writeDateTime(offsets[3], object.endDate);
  writer.writeBool(offsets[4], object.isSynced);
  writer.writeString(offsets[5], object.leaveReason);
  writer.writeString(offsets[6], object.leaveType);
  writer.writeString(offsets[7], object.leavesId);
  writer.writeBool(offsets[8], object.notificationSent);
  writer.writeBool(offsets[9], object.pendingSync);
  writer.writeDateTime(offsets[10], object.startDate);
  writer.writeString(offsets[11], object.status);
  writer.writeString(offsets[12], object.userDepartment);
  writer.writeString(offsets[13], object.userId);
  writer.writeString(offsets[14], object.username);
}

LeaveRequest _leaveRequestDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LeaveRequest();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.creatorRole = reader.readString(offsets[1]);
  object.durationDays = reader.readLong(offsets[2]);
  object.endDate = reader.readDateTime(offsets[3]);
  object.id = id;
  object.isSynced = reader.readBool(offsets[4]);
  object.leaveReason = reader.readString(offsets[5]);
  object.leaveType = reader.readString(offsets[6]);
  object.leavesId = reader.readString(offsets[7]);
  object.notificationSent = reader.readBool(offsets[8]);
  object.pendingSync = reader.readBool(offsets[9]);
  object.startDate = reader.readDateTime(offsets[10]);
  object.status = reader.readString(offsets[11]);
  object.userDepartment = reader.readString(offsets[12]);
  object.userId = reader.readString(offsets[13]);
  object.username = reader.readString(offsets[14]);
  return object;
}

P _leaveRequestDeserializeProp<P>(
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
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _leaveRequestGetId(LeaveRequest object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _leaveRequestGetLinks(LeaveRequest object) {
  return [];
}

void _leaveRequestAttach(
    IsarCollection<dynamic> col, Id id, LeaveRequest object) {
  object.id = id;
}

extension LeaveRequestQueryWhereSort
    on QueryBuilder<LeaveRequest, LeaveRequest, QWhere> {
  QueryBuilder<LeaveRequest, LeaveRequest, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LeaveRequestQueryWhere
    on QueryBuilder<LeaveRequest, LeaveRequest, QWhereClause> {
  QueryBuilder<LeaveRequest, LeaveRequest, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterWhereClause> idBetween(
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

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterWhereClause> userIdEqualTo(
      String userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'userId',
        value: [userId],
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterWhereClause> userIdNotEqualTo(
      String userId) {
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

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterWhereClause> leavesIdEqualTo(
      String leavesId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'leavesId',
        value: [leavesId],
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterWhereClause>
      leavesIdNotEqualTo(String leavesId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'leavesId',
              lower: [],
              upper: [leavesId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'leavesId',
              lower: [leavesId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'leavesId',
              lower: [leavesId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'leavesId',
              lower: [],
              upper: [leavesId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension LeaveRequestQueryFilter
    on QueryBuilder<LeaveRequest, LeaveRequest, QFilterCondition> {
  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      creatorRoleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creatorRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      creatorRoleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'creatorRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      creatorRoleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'creatorRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      creatorRoleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'creatorRole',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      creatorRoleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'creatorRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      creatorRoleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'creatorRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      creatorRoleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'creatorRole',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      creatorRoleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'creatorRole',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      creatorRoleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'creatorRole',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      creatorRoleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'creatorRole',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      durationDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationDays',
        value: value,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      durationDaysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationDays',
        value: value,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      durationDaysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationDays',
        value: value,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      durationDaysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      endDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      endDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      endDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      endDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition> idBetween(
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

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leaveReasonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'leaveReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leaveReasonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'leaveReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leaveReasonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'leaveReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leaveReasonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'leaveReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leaveReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'leaveReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leaveReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'leaveReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leaveReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'leaveReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leaveReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'leaveReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leaveReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'leaveReason',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leaveReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'leaveReason',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leaveTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'leaveType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leaveTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'leaveType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leaveTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'leaveType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leaveTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'leaveType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leaveTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'leaveType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leaveTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'leaveType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leaveTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'leaveType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leaveTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'leaveType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leaveTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'leaveType',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leaveTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'leaveType',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leavesIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'leavesId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leavesIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'leavesId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leavesIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'leavesId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leavesIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'leavesId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leavesIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'leavesId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leavesIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'leavesId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leavesIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'leavesId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leavesIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'leavesId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leavesIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'leavesId',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      leavesIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'leavesId',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      notificationSentEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationSent',
        value: value,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      pendingSyncEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pendingSync',
        value: value,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      startDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      startDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      startDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      startDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition> statusEqualTo(
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

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition> statusBetween(
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

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition> statusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      userDepartmentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userDepartment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      userDepartmentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userDepartment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      userDepartmentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userDepartment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      userDepartmentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userDepartment',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      userDepartmentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userDepartment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      userDepartmentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userDepartment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      userDepartmentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userDepartment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      userDepartmentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userDepartment',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      userDepartmentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userDepartment',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      userDepartmentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userDepartment',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition> userIdEqualTo(
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

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition> userIdBetween(
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

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
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

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      userIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition> userIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      userIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      userIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userId',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      usernameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      usernameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      usernameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      usernameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'username',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      usernameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      usernameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      usernameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      usernameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'username',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      usernameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'username',
        value: '',
      ));
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterFilterCondition>
      usernameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'username',
        value: '',
      ));
    });
  }
}

extension LeaveRequestQueryObject
    on QueryBuilder<LeaveRequest, LeaveRequest, QFilterCondition> {}

extension LeaveRequestQueryLinks
    on QueryBuilder<LeaveRequest, LeaveRequest, QFilterCondition> {}

extension LeaveRequestQuerySortBy
    on QueryBuilder<LeaveRequest, LeaveRequest, QSortBy> {
  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> sortByCreatorRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creatorRole', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy>
      sortByCreatorRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creatorRole', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> sortByDurationDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationDays', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy>
      sortByDurationDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationDays', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> sortByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> sortByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> sortByLeaveReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leaveReason', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy>
      sortByLeaveReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leaveReason', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> sortByLeaveType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leaveType', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> sortByLeaveTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leaveType', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> sortByLeavesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leavesId', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> sortByLeavesIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leavesId', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy>
      sortByNotificationSent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationSent', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy>
      sortByNotificationSentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationSent', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> sortByPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy>
      sortByPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy>
      sortByUserDepartment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userDepartment', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy>
      sortByUserDepartmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userDepartment', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> sortByUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> sortByUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.desc);
    });
  }
}

extension LeaveRequestQuerySortThenBy
    on QueryBuilder<LeaveRequest, LeaveRequest, QSortThenBy> {
  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByCreatorRole() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creatorRole', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy>
      thenByCreatorRoleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'creatorRole', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByDurationDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationDays', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy>
      thenByDurationDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationDays', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByLeaveReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leaveReason', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy>
      thenByLeaveReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leaveReason', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByLeaveType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leaveType', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByLeaveTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leaveType', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByLeavesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leavesId', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByLeavesIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leavesId', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy>
      thenByNotificationSent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationSent', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy>
      thenByNotificationSentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationSent', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy>
      thenByPendingSyncDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingSync', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy>
      thenByUserDepartment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userDepartment', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy>
      thenByUserDepartmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userDepartment', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.asc);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QAfterSortBy> thenByUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.desc);
    });
  }
}

extension LeaveRequestQueryWhereDistinct
    on QueryBuilder<LeaveRequest, LeaveRequest, QDistinct> {
  QueryBuilder<LeaveRequest, LeaveRequest, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QDistinct> distinctByCreatorRole(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'creatorRole', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QDistinct> distinctByDurationDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationDays');
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QDistinct> distinctByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endDate');
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QDistinct> distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QDistinct> distinctByLeaveReason(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'leaveReason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QDistinct> distinctByLeaveType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'leaveType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QDistinct> distinctByLeavesId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'leavesId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QDistinct>
      distinctByNotificationSent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationSent');
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QDistinct> distinctByPendingSync() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendingSync');
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QDistinct> distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QDistinct> distinctByUserDepartment(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userDepartment',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QDistinct> distinctByUserId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LeaveRequest, LeaveRequest, QDistinct> distinctByUsername(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'username', caseSensitive: caseSensitive);
    });
  }
}

extension LeaveRequestQueryProperty
    on QueryBuilder<LeaveRequest, LeaveRequest, QQueryProperty> {
  QueryBuilder<LeaveRequest, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LeaveRequest, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<LeaveRequest, String, QQueryOperations> creatorRoleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'creatorRole');
    });
  }

  QueryBuilder<LeaveRequest, int, QQueryOperations> durationDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationDays');
    });
  }

  QueryBuilder<LeaveRequest, DateTime, QQueryOperations> endDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endDate');
    });
  }

  QueryBuilder<LeaveRequest, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<LeaveRequest, String, QQueryOperations> leaveReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'leaveReason');
    });
  }

  QueryBuilder<LeaveRequest, String, QQueryOperations> leaveTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'leaveType');
    });
  }

  QueryBuilder<LeaveRequest, String, QQueryOperations> leavesIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'leavesId');
    });
  }

  QueryBuilder<LeaveRequest, bool, QQueryOperations>
      notificationSentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationSent');
    });
  }

  QueryBuilder<LeaveRequest, bool, QQueryOperations> pendingSyncProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendingSync');
    });
  }

  QueryBuilder<LeaveRequest, DateTime, QQueryOperations> startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<LeaveRequest, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<LeaveRequest, String, QQueryOperations>
      userDepartmentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userDepartment');
    });
  }

  QueryBuilder<LeaveRequest, String, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }

  QueryBuilder<LeaveRequest, String, QQueryOperations> usernameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'username');
    });
  }
}
