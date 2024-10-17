// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity =0.8.25;

import {LibSaturatingMath} from "rain.math.saturating/lib/LibSaturatingMath.sol";
import {
    FIXED_POINT_DECIMALS,
    FLAG_ROUND_UP,
    OVERFLOW_RESCALE_OOMS,
    FLAG_SATURATE
} from "src/lib/FixedPointDecimalConstants.sol";

/// @title FixedPointDecimalScaleSlow
/// @notice Slow but more obviously correct versions of all functions in
/// FixedPointScale.
///
/// Generally the functions here are slower because they include more jumps
/// because they are DRY. However, scaling values can easily be on a hot gas path
/// so we MAY inline a lot of the logic which makes them WETter. The slow and
/// fast version MAY be identical.
library LibFixedPointDecimalScaleSlow {
    function scaleUpSlow(uint256 a, uint256 scaleUpBy) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        return a * (10 ** scaleUpBy);
    }

    function scaleUpSaturatingSlow(uint256 a, uint256 scaleUpBy) internal pure returns (uint256) {
        if (scaleUpBy >= OVERFLOW_RESCALE_OOMS) {
            if (a == 0) {
                return 0;
            } else {
                return type(uint256).max;
            }
        }
        return LibSaturatingMath.saturatingMul(a, 10 ** scaleUpBy);
    }

    function scaleDownSlow(uint256 a, uint256 scaleDownBy) internal pure returns (uint256) {
        if (scaleDownBy >= OVERFLOW_RESCALE_OOMS) {
            return 0;
        }
        return a / (10 ** scaleDownBy);
    }

    function scaleDownRoundUpSlow(uint256 a, uint256 scaleDownBy) internal pure returns (uint256) {
        if (scaleDownBy >= OVERFLOW_RESCALE_OOMS) {
            if (a == 0) {
                return 0;
            } else {
                return 1;
            }
        }
        uint256 b = (10 ** scaleDownBy);
        uint256 c = a / b;
        if (c * b != a) {
            c += 1;
        }
        return c;
    }

    function scale18Slow(uint256 a, uint256 decimals, uint256 flags) internal pure returns (uint256) {
        if (FIXED_POINT_DECIMALS > decimals) {
            uint256 scaleUpBy = FIXED_POINT_DECIMALS - decimals;
            if (flags & FLAG_SATURATE != 0) {
                return scaleUpSaturatingSlow(a, scaleUpBy);
            } else {
                return scaleUpSlow(a, scaleUpBy);
            }
        }

        if (decimals > FIXED_POINT_DECIMALS) {
            uint256 scaleDownBy = decimals - FIXED_POINT_DECIMALS;
            if (flags & FLAG_ROUND_UP != 0) {
                return scaleDownRoundUpSlow(a, scaleDownBy);
            } else {
                return scaleDownSlow(a, scaleDownBy);
            }
        }

        return a;
    }

    function scaleNSlow(uint256 a, uint256 decimals, uint256 flags) internal pure returns (uint256) {
        if (FIXED_POINT_DECIMALS > decimals) {
            uint256 scaleDownBy = FIXED_POINT_DECIMALS - decimals;
            if (flags & FLAG_ROUND_UP != 0) {
                return scaleDownRoundUpSlow(a, scaleDownBy);
            } else {
                return scaleDownSlow(a, scaleDownBy);
            }
        }

        if (decimals > FIXED_POINT_DECIMALS) {
            uint256 scaleUpBy = decimals - FIXED_POINT_DECIMALS;
            if (flags & FLAG_SATURATE != 0) {
                return scaleUpSaturatingSlow(a, scaleUpBy);
            } else {
                return scaleUpSlow(a, scaleUpBy);
            }
        }

        return a;
    }

    function scaleBySlow(uint256 a, int8 ooms, uint256 flags) internal pure returns (uint256) {
        if (ooms > 0) {
            if (flags & FLAG_SATURATE != 0) {
                return scaleUpSaturatingSlow(a, uint8(ooms));
            } else {
                return scaleUpSlow(a, uint8(ooms));
            }
        }

        if (ooms < 0) {
            uint8 scaleDownBy = ooms == -128 ? 128 : uint8(-1 * ooms);
            if (flags & FLAG_ROUND_UP != 0) {
                return scaleDownRoundUpSlow(a, scaleDownBy);
            } else {
                return scaleDownSlow(a, scaleDownBy);
            }
        }

        return a;
    }
}
