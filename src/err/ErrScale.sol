// SPDX-License-Identifier: CAL
pragma solidity ^0.8.25;

/// @dev Thrown when downscaling would result in precision loss in a lossless
/// conversion.
/// @param a The value that would lose precision.
error ErrScaleDownPrecisionLoss(uint256 a);
