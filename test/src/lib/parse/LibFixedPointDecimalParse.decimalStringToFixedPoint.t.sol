// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";

import {LibFixedPointDecimalParse} from "src/lib/parse/LibFixedPointDecimalParse.sol";
import {ParseDecimalInvalidString, ParseDecimalPrecisionLoss} from "src/error/ErrParse.sol";
import {ParseEmptyDecimalString, ParseDecimalOverflow} from "rain-string-0.1.0/src/error/ErrParse.sol";

contract LibFixedPointDecimalParseTest is Test {
    function checkDecimalStringToFixedPoint(string memory value, uint256 expected) internal pure {
        (bytes4 errorSelector, uint256 parsed) = LibFixedPointDecimalParse.decimalStringTofixedPoint(value);
        assertEq(errorSelector, 0);
        assertEq(parsed, expected);
    }

    function checkDecimalStringToFixedPointFailure(string memory value, bytes4 expected) internal pure {
        (bytes4 errorSelector,) = LibFixedPointDecimalParse.decimalStringTofixedPoint(value);
        assertEq(errorSelector, expected);
    }

    function testDecimalStringToFixedPointExamples() external pure {
        checkDecimalStringToFixedPoint("0", 0);
        checkDecimalStringToFixedPoint("0.0", 0);
        checkDecimalStringToFixedPoint("1", 1e18);
        checkDecimalStringToFixedPoint("1.0", 1e18);
        checkDecimalStringToFixedPoint("10", 10e18);
        checkDecimalStringToFixedPoint("10.0", 10e18);
        checkDecimalStringToFixedPoint("100", 100e18);
        checkDecimalStringToFixedPoint("1000", 1000e18);
        checkDecimalStringToFixedPoint("10000", 10000e18);
        checkDecimalStringToFixedPoint("0.1", 0.1e18);
        checkDecimalStringToFixedPoint("0.01", 0.01e18);
        checkDecimalStringToFixedPoint("0.001", 0.001e18);
        checkDecimalStringToFixedPoint("0.0001", 0.0001e18);
        checkDecimalStringToFixedPoint("0.00001", 0.00001e18);
        checkDecimalStringToFixedPoint("0.000001", 0.000001e18);
        checkDecimalStringToFixedPoint("0.0000001", 0.0000001e18);
        checkDecimalStringToFixedPoint("0.00000001", 0.00000001e18);
        checkDecimalStringToFixedPoint("0.000000001", 0.000000001e18);
        checkDecimalStringToFixedPoint("0.0000000001", 0.0000000001e18);
        checkDecimalStringToFixedPoint("0.00000000001", 0.00000000001e18);
        checkDecimalStringToFixedPoint("0.000000000001", 0.000000000001e18);
        checkDecimalStringToFixedPoint("0.0000000000001", 0.0000000000001e18);
        checkDecimalStringToFixedPoint("0.00000000000001", 0.00000000000001e18);
        checkDecimalStringToFixedPoint("0.000000000000001", 0.000000000000001e18);
        checkDecimalStringToFixedPoint("0.0000000000000001", 0.0000000000000001e18);
        checkDecimalStringToFixedPoint("0.00000000000000001", 0.00000000000000001e18);
        checkDecimalStringToFixedPoint("0.000000000000000001", 0.000000000000000001e18);
        checkDecimalStringToFixedPoint("1.1", 1.1e18);
        checkDecimalStringToFixedPoint("1.10101010101010101", 1.10101010101010101e18);
        checkDecimalStringToFixedPoint(
            "115792089237316195423570985008687907853269984665640564039457.584007913129639935", type(uint256).max
        );
        checkDecimalStringToFixedPoint("0.010101010101010101", 10101010101010101);

        // Trailing zeros.
        checkDecimalStringToFixedPoint("1.000000000000000000", 1e18);
        checkDecimalStringToFixedPoint("1.100000000000000000", 1.1e18);
        checkDecimalStringToFixedPoint("1.101010101010101010", 1.10101010101010101e18);
        checkDecimalStringToFixedPoint(
            "115792089237316195423570985008687907853269984665640564039457.5840079131296399350", type(uint256).max
        );
        checkDecimalStringToFixedPoint(
            "115792089237316195423570985008687907853269984665640564039457.58400791312963993500000000", type(uint256).max
        );

        // Leading zeros.
        checkDecimalStringToFixedPoint("0000001", 1e18);
        checkDecimalStringToFixedPoint("0000001.000000000000000000", 1e18);
        checkDecimalStringToFixedPoint("0000001.100000000000000000", 1.1e18);
        checkDecimalStringToFixedPoint("0000001.101010101010101010", 1.10101010101010101e18);
        checkDecimalStringToFixedPoint(
            "000000115792089237316195423570985008687907853269984665640564039457.584007913129639935", type(uint256).max
        );

        // Leading and trailing zeros.
        checkDecimalStringToFixedPoint("0000001.000000000000000000", 1e18);
        checkDecimalStringToFixedPoint("0000001.100000000000000000", 1.1e18);
        checkDecimalStringToFixedPoint("0000001.101010101010101010", 1.10101010101010101e18);
        checkDecimalStringToFixedPoint(
            "000000115792089237316195423570985008687907853269984665640564039457.5840079131296399350000",
            type(uint256).max
        );
    }

    /// Failure due to corrupt integer.
    function testDecimalStringToFixedPointFailureCorruptInteger() external pure {
        checkDecimalStringToFixedPointFailure("1a1.1", ParseDecimalInvalidString.selector);
        checkDecimalStringToFixedPointFailure("1.1a1", ParseDecimalInvalidString.selector);
        checkDecimalStringToFixedPointFailure("1.1.1", ParseDecimalInvalidString.selector);
        checkDecimalStringToFixedPointFailure("a1.1", ParseEmptyDecimalString.selector);
    }

    /// Failure due to precision loss.
    function testDecimalStringToFixedPointFailurePrecisionLoss() external pure {
        checkDecimalStringToFixedPointFailure(
            "115792089237316195423570985008687907853269984665640564039457.5840079131296399355",
            ParseDecimalPrecisionLoss.selector
        );
    }

    /// Failure due to overflow.
    function testDecimalStringToFixedPointFailureOverflow() external pure {
        checkDecimalStringToFixedPointFailure(
            "115792089237316195423570985008687907853269984665640564039457.584007913129639936",
            ParseDecimalOverflow.selector
        );
        checkDecimalStringToFixedPointFailure(
            "1115792089237316195423570985008687907853269984665640564039457.584007913129639935",
            ParseDecimalOverflow.selector
        );
    }

    /// Failure because the FRACTIONAL part itself overflows a `uint256` while
    /// being parsed by `unsafeDecimalStringToInt`, before the digit-count
    /// precision-loss check is reached. A frac of 78 nines cannot fit in a
    /// `uint256` so the inner integer parse returns `ParseDecimalOverflow`, and
    /// that selector is propagated unchanged from the fractional-parse error
    /// branch.
    function testDecimalStringToFixedPointFailureFractionalPartOverflow() external pure {
        // 78 nines after the point. 1e78 > type(uint256).max so the inner
        // unsafeDecimalStringToInt overflows.
        checkDecimalStringToFixedPointFailure(
            "0.999999999999999999999999999999999999999999999999999999999999999999999999999999",
            ParseDecimalOverflow.selector
        );
        // 79 digits, leading non-zero, also overflows the inner integer parse.
        checkDecimalStringToFixedPointFailure(
            "0.9000000000000000000000000000000000000000000000000000000000000000000000000000009",
            ParseDecimalOverflow.selector
        );
    }

    /// A character immediately after the integer part that is NOT a decimal
    /// point must be rejected as an invalid string by the decimal-point gate.
    /// Critically, `"1x"` has no further input after the bad character, so if
    /// the decimal-point gate is bypassed the parse wrongly SUCCEEDS as `1e18`
    /// rather than erroring; this is what distinguishes the decimal-point gate
    /// from the downstream trailing-garbage gate (which the pre-existing corrupt
    /// integer tests already reach via inputs whose garbage is caught later).
    function testDecimalStringToFixedPointInvalidAfterInteger() external pure {
        // Non-point character directly after the integer, with nothing after it,
        // so the decimal-point gate is the only thing that can reject it.
        checkDecimalStringToFixedPointFailure("1x", ParseDecimalInvalidString.selector);
        checkDecimalStringToFixedPointFailure("10x", ParseDecimalInvalidString.selector);
        // A bare trailing decimal point with no fractional digits is a valid
        // empty fraction and parses as the integer value (the gate accepts the
        // point itself).
        checkDecimalStringToFixedPoint("1.", 1e18);
    }
}
