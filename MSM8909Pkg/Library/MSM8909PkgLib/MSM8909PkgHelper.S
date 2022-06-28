#
#  Copyright (c) 2018, Linaro Limited. All rights reserved.
#
#  This program and the accompanying materials
#  are licensed and made available under the terms and conditions of the BSD License
#  which accompanies this distribution.  The full text of the license may be found at
#  http://opensource.org/licenses/bsd-license.php
#
#  THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
#  WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.
#
#

#include <AsmMacroIoLib.h>
#include <Library/ArmLib.h>

.text
.align 3

ASM_FUNC(ArmPlatformPeiBootAction)
startlabel:
  // check if we're located at expected location
  adr	r4, .
  ldr	r5, =ArmPlatformPeiBootAction
  cmp	r4, r5
  bne	docopy
  bx   lr
docopy:
  // find our start address by getting our expected offset, then subtracting it from our actual address
  ldr	r6, =FixedPcdGet64 (PcdFdBaseAddress)
  sub	r5, r5, r6 // r5 now holds offset of ArmPlatformPeiBootAction from start of FD base
  sub	r4, r4, r5 // r4 now holds address of actual FD base
  // tweak the return address
  // note: r14 is lr; gcc5 doesn't have the alias
  sub	r14, r14, r4
  add	r14, r14, r6
  ldr	r5, =FixedPcdGet64 (PcdFdSize)
  // crap memcpy
loop:
  ldp	r2, r3, [r4], #8
  stp	r2, r3, [r6], #8
  subs	r5, r5, #8
  b.ne	loop
  bx    lr
.ltorg

//UINTN
//ArmPlatformIsPrimaryCore (
//  IN UINTN MpId
//  );
ASM_FUNC(ArmPlatformIsPrimaryCore)
  MOV32 (r1, FixedPcdGet32(PcdArmPrimaryCoreMask))
  and   r0, r0, r1

  LDRL (r1, FixedPcdGet32(PcdArmPrimaryCore))

  cmp   r0, r1
  moveq r0, #1
  movne r0, #0
  bx    lr

//UINTN
//ArmPlatformGetPrimaryCoreMpId (
//  VOID
//  );
ASM_FUNC(ArmPlatformGetPrimaryCoreMpId)
  LDRL  (r0, PrimaryCoreMpid)
  bx    lr

//UINTN
//ArmPlatformGetCorePosition (
//  IN UINTN MpId
//  );
// With this function: CorePos = (ClusterId * 4) + CoreId
ASM_FUNC(ArmPlatformGetCorePosition)
  and   r1, r0, #ARM_CORE_MASK
  and   r0, r0, #ARM_CLUSTER_MASK
  add   r0, r1, r0, LSR #7
  bx    lr
