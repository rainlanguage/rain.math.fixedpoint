// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "src/lib/LibWillOverflow.sol";
import "src/lib/LibFixedPointDecimalScale.sol";
import "./LibFixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScale18 is Test {
    function testScale18ReferenceImplementation(uint256 a_, uint256 decimals_, uint256 flags_) public {
        vm.assume(flags_ <= FLAG_MAX_INT);
        vm.assume(!LibWillOverflow.scale18WillOverflow(a_, decimals_, flags_));

        assertEq(
            LibFixedPointDecimalScaleSlow.scale18Slow(a_, decimals_, flags_),
            LibFixedPointDecimalScale.scale18(a_, decimals_, flags_)
        );
    }

    function testScale1818(uint256 a_, uint256 flags_) public {
        vm.assume(flags_ <= FLAG_MAX_INT);
        assertEq(a_, LibFixedPointDecimalScale.scale18(a_, FIXED_POINT_DECIMALS, flags_));
    }

    function testScale18Lt(uint256 a_, uint256 decimals_, uint256 flags_) public {
        // Only keep rounding flags.
        flags_ = flags_ & FLAG_ROUND_UP;
        vm.assume(decimals_ < FIXED_POINT_DECIMALS);

        uint256 scaleUpBy_ = FIXED_POINT_DECIMALS - decimals_;
        vm.assume(!LibWillOverflow.scaleUpWillOverflow(a_, scaleUpBy_));

        assertEq(
            LibFixedPointDecimalScale.scaleUp(a_, scaleUpBy_), LibFixedPointDecimalScale.scale18(a_, decimals_, flags_)
        );
        assertEq(
            LibFixedPointDecimalScale.scaleUpSaturating(a_, scaleUpBy_),
            LibFixedPointDecimalScale.scale18(a_, decimals_, flags_)
        );
    }

    function testScale18LtOverflow(uint256 a_, uint8 decimals_, uint256 flags_) public {
        // Only keep rounding flags.
        flags_ = flags_ & FLAG_ROUND_UP;
        vm.assume(decimals_ < FIXED_POINT_DECIMALS);

        uint256 scaleUpBy_ = FIXED_POINT_DECIMALS - decimals_;
        vm.assume(LibWillOverflow.scaleUpWillOverflow(a_, scaleUpBy_));

        vm.expectRevert(stdError.arithmeticError);
        LibFixedPointDecimalScale.scale18(a_, decimals_, flags_);
    }

    function testScale18LtSaturate(uint256 a_, uint256 decimals_, uint256 flags_) public {
        // Keep rounding flags.
        flags_ = FLAG_SATURATE | (flags_ & FLAG_ROUND_UP);
        vm.assume(decimals_ < FIXED_POINT_DECIMALS);

        uint256 scaleUpBy_ = FIXED_POINT_DECIMALS - decimals_;

        assertEq(
            LibFixedPointDecimalScale.scaleUpSaturating(a_, scaleUpBy_),
            LibFixedPointDecimalScale.scale18(a_, decimals_, flags_)
        );
    }

    function testScale18Gt(uint256 a_, uint8 decimals_, uint256 flags_) public {
        // Keep saturate flags.
        flags_ = flags_ & FLAG_SATURATE;
        vm.assume(decimals_ > FIXED_POINT_DECIMALS);

        uint256 scaleDownBy_ = decimals_ - FIXED_POINT_DECIMALS;

        assertEq(
            LibFixedPointDecimalScale.scaleDown(a_, scaleDownBy_),
            LibFixedPointDecimalScale.scale18(a_, decimals_, flags_)
        );
    }

    function testScale18GtRoundUp(uint256 a_, uint8 decimals_, uint256 flags_) public {
        // Keep saturate flags.
        flags_ = FLAG_ROUND_UP | (flags_ & FLAG_SATURATE);
        vm.assume(decimals_ > FIXED_POINT_DECIMALS);

        uint256 scaleDownBy_ = decimals_ - FIXED_POINT_DECIMALS;

        assertEq(
            LibFixedPointDecimalScale.scaleDownRoundUp(a_, scaleDownBy_),
            LibFixedPointDecimalScale.scale18(a_, decimals_, flags_)
        );
    }
}
