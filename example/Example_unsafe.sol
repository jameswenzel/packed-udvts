// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

type UDVT is uint256;

using UDVTType for UDVT global;

library UDVTType {
    uint256 constant BAR_END_MASK = 0x7fffffff;
    uint256 constant BAR_EXPANSION_BITS = 224;
    uint256 constant BAR_NOT_MASK = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffff80000000ff;
    uint256 constant BAR_OFFSET = 8;
    uint256 constant BAZ_END_MASK = 0x1fffffffffffffffff;
    uint256 constant BAZ_NOT_MASK = 0xfffffffffffffffffffffffffffffffffffff000000000000000007fffffffff;
    uint256 constant BAZ_OFFSET = 39;
    uint256 constant FOO_END_MASK = 0xff;
    uint256 constant FOO_NOT_MASK = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00;

    function createUDVT(int256 _foo, bytes32 _bar, uint256 _baz) internal pure returns (UDVT self) {
        assembly {
            self := _foo
            self := or(self, shl(BAR_OFFSET, shr(224, _bar)))
            self := or(self, shl(BAZ_OFFSET, _baz))
        }
    }

    function unpackUDVT(UDVT self) internal pure returns (int256 _foo, bytes32 _bar, uint256 _baz) {
        assembly {
            _foo := signextend(0, and(self, FOO_END_MASK))
            _bar := shl(BAR_EXPANSION_BITS, and(shr(BAR_OFFSET, self), BAR_END_MASK))
            _baz := and(shr(BAZ_OFFSET, self), BAZ_END_MASK)
        }
    }

    function getFoo(UDVT self) internal pure returns (int256 _foo) {
        assembly {
            _foo := signextend(0, and(self, FOO_END_MASK))
        }
    }

    function getBar(UDVT self) internal pure returns (bytes32 _bar) {
        assembly {
            _bar := shl(BAR_EXPANSION_BITS, and(shr(BAR_OFFSET, self), BAR_END_MASK))
        }
    }

    function getBaz(UDVT self) internal pure returns (uint256 _baz) {
        assembly {
            _baz := and(shr(BAZ_OFFSET, self), BAZ_END_MASK)
        }
    }

    function setFoo(UDVT self, int256 _foo) internal pure returns (UDVT updated) {
        assembly {
            updated := or(and(self, FOO_NOT_MASK), and(_foo, FOO_END_MASK))
        }
    }

    function setBar(UDVT self, bytes32 _bar) internal pure returns (UDVT updated) {
        assembly {
            updated := or(and(self, BAR_NOT_MASK), shl(BAR_OFFSET, shr(BAR_EXPANSION_BITS, _bar)))
        }
    }

    function setBaz(UDVT self, uint256 _baz) internal pure returns (UDVT updated) {
        assembly {
            updated := or(and(self, BAZ_NOT_MASK), shl(BAZ_OFFSET, _baz))
        }
    }
}
