from unittest import TestCase
from packed_udvts.udvt import UserDefinedValueType
from packed_udvts.region import Region
from packed_udvts.member import Member

foo_member = Member(name="foo", width_bits=8, bytesN=None, signed=True)
foo_region = Region(member=foo_member, offset_bits=0)
bar_member = Member(name="bar", width_bits=31, bytesN=4, signed=False)
bar_region = Region(member=bar_member, offset_bits=8)
baz_member = Member(name="baz", width_bits=69, bytesN=None, signed=False)
baz_region = Region(member=baz_member, offset_bits=39)
u = UserDefinedValueType(
    name="UDVT", regions=[foo_region, bar_region], value_type="uint256"
)


class TestUserDefinedValueType(TestCase):
    u: UserDefinedValueType

    def setUp(self) -> None:
        self.u = UserDefinedValueType(
            name="UDVT",
            regions=[foo_region, bar_region, baz_region],
            value_type="uint256",
        )
        self.maxDiff = 6969

    def test_type_declaration(self):
        self.assertEqual(self.u.type_declaration, "type UDVT is uint256;")
        self.u = UserDefinedValueType(
            name="Foo", regions=[foo_region], value_type="bytes32"
        )
        self.assertEqual(self.u.type_declaration, "type Foo is bytes32;")
        with self.assertRaises(AssertionError):
            UserDefinedValueType(name="Foo", regions=[foo_region], value_type="uint128")  # type: ignore

    def test_using_declaration(self):
        self.assertEqual(self.u.using_declaration, "using UDVTType for UDVT global;")
        self.u = UserDefinedValueType(
            name="Foo", regions=[foo_region], value_type="bytes32"
        )
        self.assertEqual(self.u.using_declaration, "using FooType for Foo global;")

    def test_create_declaration(self):
        create_declaration = f"""
function createUDVT(int8 _foo, bytes4 _bar, uint72 _baz) internal pure returns (UDVT self) {{
    assembly {{
        self := _foo
        self := or(self, shl(8, shr(224, _bar)))
        self := or(self, shl(39, _baz))
    }}
}}"""
        self.assertEqual(self.u.create_declaration(typesafe=True), create_declaration)

    def test_unpack_declaration(self):
        create_declaration = f"""
function unpackUDVT(UDVT self) internal pure returns (int8 _foo, bytes4 _bar, uint72 _baz) {{
    assembly {{
        _foo := signextend(0, and(self, FOO_END_MASK))
        _bar := shl(224, and(shr(8, self), BAR_END_MASK))
        _baz := and(shr(39, self), BAZ_END_MASK)
    }}
}}"""
        self.assertEqual(self.u.unpack_declaration(typesafe=True), create_declaration)