@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Class 8.05: Loyalty member'
define view entity ZCDS_I_08_05_MEMBER
  as select from ztb_08_05_member as Member
  association [1..1] to ztb_08_05_loyprg as _Program
    on $projection.ProgramId = _Program.program_id
  association [1..1] to /dmo/customer    as _Customer
    on $projection.CustomerId = _Customer.customer_id
  association [0..*] to ztb_08_05_points as _Points
    on $projection.MemberId = _Points.member_id
{
  key Member.member_id      as MemberId,
      Member.program_id     as ProgramId,
      Member.customer_id    as CustomerId,
      Member.tier           as Tier,
      Member.joined_on      as JoinedOn,
      Member.points_balance as PointsBalance,
      _Program,
      _Customer,
      _Points
}
