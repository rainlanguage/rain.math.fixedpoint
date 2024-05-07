// SPDX-License-Identifier: CAL
pragma solidity =0.8.19;

import "forge-std/Test.sol";
import "src/lib/LibWillOverflow.sol";
import "src/lib/LibFixedPointDecimalScale.sol";
import "./LibFixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScaleBy is Test {
    function testScaleByReferenceImplementation(uint256 a, int8 scaleBy, uint256 flags) public {
        vm.assume(flags <= FLAG_MAX_INT);
        vm.assume(!LibWillOverflow.scaleByWillOverflow(a, scaleBy, flags));

        assertEq(
            LibFixedPointDecimalScaleSlow.scaleBySlow(a, scaleBy, flags),
            LibFixedPointDecimalScale.scaleBy(a, scaleBy, flags)
        );
    }

    function testScaleBy0(uint256 a, uint256 flags) public {
        vm.assume(flags <= FLAG_MAX_INT);

        assertEq(a, LibFixedPointDecimalScale.scaleBy(a, 0, flags));
    }

    function testScaleByUp(uint256 a, int8 scaleBy, uint256 flags) public {
        // Keep rounding flag.
        flags = flags & FLAG_ROUND_UP;
        vm.assume(scaleBy > 0);
        vm.assume(!LibWillOverflow.scaleUpWillOverflow(a, uint8(scaleBy)));

        assertEq(
            LibFixedPointDecimalScale.scaleUp(a, uint8(scaleBy)), LibFixedPointDecimalScale.scaleBy(a, scaleBy, flags)
        );
    }

    function testScaleByUpOverflow(uint256 a, int8 scaleBy, uint256 flags) public {
        // Keep rounding flag.
        flags = flags & FLAG_ROUND_UP;
        vm.assume(scaleBy > 0);
        vm.assume(LibWillOverflow.scaleUpWillOverflow(a, uint8(scaleBy)));
        vm.expectRevert(stdError.arithmeticError);
        LibFixedPointDecimalScale.scaleBy(a, scaleBy, flags);
    }

    function testScaleByUpSaturate(uint256 a, int8 scaleBy, uint256 flags) public {
        // Keep rounding flag.
        flags = FLAG_SATURATE | (flags & FLAG_ROUND_UP);
        vm.assume(scaleBy > 0);

        assertEq(
            LibFixedPointDecimalScale.scaleUpSaturating(a, uint8(scaleBy)),
            LibFixedPointDecimalScale.scaleBy(a, scaleBy, flags)
        );
    }

    function testScaleByDown(uint256 a, int8 scaleBy, uint256 flags) public {
        // Keep saturate flag.
        flags = flags & FLAG_SATURATE;
        vm.assume(scaleBy < 0);

        assertEq(
            LibFixedPointDecimalScale.scaleBy(a, scaleBy, flags),
            LibFixedPointDecimalScale.scaleDown(a, stdMath.abs(scaleBy))
        );
    }

    function testScaleByDownRoundUp(uint256 a, int8 scaleBy, uint256 flags) public {
        // Keep saturate flag.
        flags = FLAG_ROUND_UP | (flags & FLAG_SATURATE);
        vm.assume(scaleBy < 0);

        assertEq(
            LibFixedPointDecimalScale.scaleBy(a, scaleBy, flags),
            LibFixedPointDecimalScale.scaleDownRoundUp(a, stdMath.abs(scaleBy))
        );
    }
}
