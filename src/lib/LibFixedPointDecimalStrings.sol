// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {FIXED_POINT_ONE} from "./FixedPointDecimalConstants.sol";
import {Strings} from "openzeppelin-contracts/contracts/utils/Strings.sol";
import {LibParseChar} from "rain.string/lib/parse/LibParseChar.sol";
import {CMASK_NUMERIC_0_9, CMASK_DECIMAL_POINT} from "rain.string/lib/parse/LibParseCMask.sol";
import {LibParseDecimal} from "rain.string/lib/parse/LibParseDecimal.sol";
import {ParseDecimalPrecisionLoss, ParseDecimalInvalidString} from "../error/ErrParse.sol";

library LibFixedPointDecimalStrings {}
