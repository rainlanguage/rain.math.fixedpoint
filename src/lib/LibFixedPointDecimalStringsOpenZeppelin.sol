// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity ^0.8.25;

import {FIXED_POINT_ONE} from "./FixedPointDecimalConstants.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {LibParseChar} from "rain.string/lib/parse/LibParseChar.sol";
import {CMASK_NUMERIC_0_9, CMASK_DECIMAL_POINT} from "rain.string/lib/parse/LibParseCMask.sol";

library LibFixedPointDecimalStringsOpenZeppelin {
    /// @notice Convert a fixed point decimal to a string representation.
    /// Trailing zeros are removed and decimals are only included if the value is
    /// non-integer as fixed point decimals.
    /// e.g. `1e18` -> "1", `1.1e18` -> "1.1", `0.1e18` -> "0.1"
    /// @param value The fixed point decimal to convert.
    function fixedPointToDecimalString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 integral = value / FIXED_POINT_ONE;
            uint256 frac = value % FIXED_POINT_ONE;

            string memory integralString = Strings.toString(integral);

            if (frac == 0) {
                return integralString;
            }

            // Can't overflow because frac is less than FIXED_POINT_ONE.
            uint256 fracPlusOne = frac + FIXED_POINT_ONE;

            // Stringifying fracPlusOne preserves the leading zeros in our frac
            // as a string decimal, but also introduces trailing zeros. We need
            // to slice out the leading "1" digit and trailing zeros manually.
            string memory fracString = Strings.toString(fracPlusOne);

            uint256 trailingZeros = 0;
            uint256 divisor = 10;
            // Divide first to try to discover imprecision due to a suspected
            // trailing zero being non-zero. Also means we cannot overflow.
            //slither-disable-next-line divide-before-multiply
            while (fracPlusOne == (fracPlusOne / divisor) * divisor) {
                trailingZeros += 1;
                divisor *= 10;
            }

            assembly ("memory-safe") {
                // This can't underflow because we're always guaranteed at least
                // one non-zero digit in fracString due to the +FIXED_POINT_ONE.
                // If it underflows that implies we miscalculated trailingZeros.
                let newLength := sub(mload(fracString), add(1, trailingZeros))
                // We can write newlength directly over the old length and
                // leading "1" digit in fracString. This saves us having to
                // allocate and copy memory.
                fracString := add(fracString, 1)
                mstore(fracString, newLength)
            }

            return string(abi.encodePacked(integralString, ".", fracString));
        }
    }

    function decimalStringTofixedPoint(string memory str) internal pure returns (bool, uint256) {
        unchecked {
            uint256 start;
            uint256 end;
            assembly ("memory-safe") {
                start := add(str, 0x20)
                end := add(start, mload(str))
            }
            uint256 cursor = start;

            cursor = LibParseChar.skipMask(start, end, CMASK_NUMERIC_0_9);
            (bool successInt, uint256 integer) = unsafeDecimalStringToInt(start, cursor);
            if (!successInt) {
                return (false, 0);
            }

            uint256 value = integer * FIXED_POINT_ONE;

            if (cursor < end) {
                // Skip the decimal point or bail if there isn't one.
                if (LibParseChar.isMask(cursor, end, CMASK_DECIMAL_POINT) == 0) {
                    return (false, 0);
                }

                cursor++;
                uint256 fracStart = cursor;
                cursor = LibParseChar.skipMask(cursor, end, CMASK_NUMERIC_0_9);

                // Ensure there's no unprocessed garbage.
                if (cursor < end) {
                    return (false, 0);
                }

                (bool successFrac, uint256 frac) = unsafeDecimalStringToInt(fracStart, cursor);
                uint256 digits = cursor - fracStart;
                if (!successFrac || digits > 18) {
                    return (false, 0);
                }

                uint256 ooms = 18 - digits;
                value += frac * 10 ** ooms;
            }
            return (true, value);
        }
    }

    /// @notice Convert a decimal ASCII string in a memory region to an
    /// 18 decimal fixed point `uint256`.
    /// DOES NOT check that the string contains valid decimal characters.
    /// DOES check for overflow in the fixed point representation.
    /// @param start The start of the memory region containing the decimal ASCII
    /// string.
    /// @param end The end of the memory region containing the decimal ASCII
    /// string.
    /// @return success Whether the conversion was successful. If false, this is
    /// due to an overflow.
    /// @return value The fixed point decimal representation of the ASCII string.
    /// ALWAYS check `success` before using `value`, otherwise you cannot
    /// distinguish between `0` and a failed conversion.
    function unsafeDecimalStringToInt(uint256 start, uint256 end) internal pure returns (bool, uint256) {
        unchecked {
            // The ASCII byte can be translated to a numeric digit by subtracting
            // the digit offset.
            uint256 digitOffset = uint256(uint8(bytes1("0")));
            uint256 exponent = 0;
            uint256 cursor;
            cursor = end - 1;
            uint256 value = 0;

            // Anything under 10^77 is safe to raise to its power of 10 without
            // overflowing a uint256.
            while (cursor >= start && exponent < 77) {
                // We don't need to check the bounds of the byte because
                // we know it is a decimal literal as long as the bounds
                // are correct (calculated in `boundLiteral`).
                assembly ("memory-safe") {
                    value := add(value, mul(sub(byte(0, mload(cursor)), digitOffset), exp(10, exponent)))
                }
                exponent++;
                cursor--;
            }

            // If we didn't consume the entire literal, then we have
            // to check if the remaining digit is safe to multiply
            // by 10 without overflowing a uint256.
            if (cursor >= start) {
                {
                    uint256 digit;
                    assembly ("memory-safe") {
                        digit := sub(byte(0, mload(cursor)), digitOffset)
                    }
                    // If the digit is greater than 1, then we know that
                    // multiplying it by 10^77 will overflow a uint256.
                    if (digit > 1) {
                        return (false, 0);
                    } else {
                        uint256 scaled = digit * (10 ** exponent);
                        if (value + scaled < value) {
                            return (false, 0);
                        }
                        value += scaled;
                    }
                    cursor--;
                }

                {
                    // If we didn't consume the entire literal, then only
                    // leading zeros are allowed.
                    while (cursor >= start) {
                        //slither-disable-next-line similar-names
                        uint256 decimalCharByte;
                        assembly ("memory-safe") {
                            decimalCharByte := byte(0, mload(cursor))
                        }
                        if (decimalCharByte != uint256(uint8(bytes1("0")))) {
                            return (false, 0);
                        }
                        cursor--;
                    }
                }
            }

            return (true, value);
        }
    }
}
