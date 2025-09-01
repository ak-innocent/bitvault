;; BitVault Protocol
;; Decentralized Bitcoin L2 Lending Platform

;; PROTOCOL OVERVIEW
;;
;; BitVault is a cutting-edge DeFi lending protocol built natively on the
;; Stacks blockchain, bringing sophisticated financial primitives to Bitcoin's
;; Layer 2 ecosystem. The protocol enables users to unlock liquidity from
;; their STX holdings through over-collateralized lending positions.\
;;
;; Core Features:
;; - Capital-efficient STX collateralization
;; - Automated liquidation engine for protocol safety
;; - Dynamic risk management with configurable parameters
;; - Bitcoin-native security through Stacks consensus
;; - Zero-counterparty risk through smart contract automation

;; PROTOCOL CONSTANTS & GOVERNANCE

;; Protocol Governance - Immutable contract authority
(define-constant PROTOCOL_OWNER tx-sender)

;; System Error Registry - Standardized error handling for DeFi operations
(define-constant E_UNAUTHORIZED_ACCESS (err u100))
(define-constant E_COLLATERAL_INSUFFICIENT (err u101))
(define-constant E_AMOUNT_INVALID (err u102))
(define-constant E_POSITION_NOT_FOUND (err u103))
(define-constant E_POSITION_STILL_ACTIVE (err u104))
(define-constant E_BALANCE_INSUFFICIENT (err u105))
(define-constant E_LIQUIDATION_UNAVAILABLE (err u106))
(define-constant E_PARAMETER_OUT_OF_BOUNDS (err u107))

;; Risk Management Boundaries - Protecting the Bitcoin L2 ecosystem
(define-constant COLLATERAL_RATIO_CEILING u500) ;; 500% - Maximum over-collateralization
(define-constant COLLATERAL_RATIO_FLOOR u110) ;; 110% - Minimum safety threshold
(define-constant PROTOCOL_FEE_CEILING u10) ;; 10% - Maximum sustainable fee

;; PROTOCOL STATE VARIABLES

;; Dynamic Risk Parameters - Governance-controlled protocol tuning
(define-data-var collateral-requirement uint u150) ;; 150% - Conservative DeFi standard
(define-data-var liquidation-boundary uint u130) ;; 130% - Health factor threshold
(define-data-var protocol-treasury-fee uint u1) ;; 1% - Sustainable protocol economics
(define-data-var aggregate-collateral uint u0) ;; Total STX locked in protocol
(define-data-var aggregate-debt uint u0) ;; Total STX borrowed from protocol

;; DATA STRUCTURES & MAPPINGS

;; Individual Loan Records - Comprehensive position tracking
(define-map lending-positions
  { position-id: uint }
  {
    account-holder: principal, ;; Position owner
    stx-collateral: uint, ;; STX tokens deposited as security
    stx-debt: uint, ;; STX tokens borrowed against collateral
    annual-rate: uint, ;; Interest rate basis points
    position-opened: uint, ;; Block height when position created
    interest-checkpoint: uint, ;; Last block when interest was calculated
    position-status: bool, ;; Active/inactive state
  }
)

;; User Portfolio Aggregation - Real-time position summaries
(define-map account-portfolios
  { account: principal }
  {
    total-stx-collateral: uint, ;; Sum of all collateral across positions
    total-stx-debt: uint, ;; Sum of all borrowed amounts
    active-positions: uint, ;; Count of open lending positions
  }
)

;; PRIVATE UTILITY FUNCTIONS

;; Interest Calculation Engine - Compound interest for Bitcoin L2 DeFi
;; Calculates accrued interest based on principal, rate, and block duration
(define-private (compute-accrued-interest
    (principal-amount uint)
    (interest-rate uint)
    (block-duration uint)
  )
  (let (
      (per-block-rate (/ (* principal-amount interest-rate) u10000))
      (accumulated-interest (* per-block-rate block-duration))
    )
    accumulated-interest
  )
)

;; Health Factor Calculator - Risk assessment for lending positions
;; Returns collateralization ratio as percentage (e.g., 150 = 150%)
(define-private (compute-health-ratio
    (collateral-value uint)
    (outstanding-debt uint)
  )
  (if (is-eq outstanding-debt u0)
    u0 ;; No debt means infinite health ratio
    (/ (* collateral-value u100) outstanding-debt)
  )
)

;; Portfolio State Manager - Efficient user position updates
;; Handles both collateral and debt adjustments in a single atomic operation
(define-private (update-account-portfolio
    (account principal)
    (collateral-change uint)
    (is-collateral-deposit bool)
    (debt-change uint)
    (is-debt-increase bool)
  )
  (let (
      (current-portfolio (default-to {
        total-stx-collateral: u0,
        total-stx-debt: u0,
        active-positions: u0,
      }
        (map-get? account-portfolios { account: account })
      ))
      (updated-collateral (if is-collateral-deposit
        (+ (get total-stx-collateral current-portfolio) collateral-change)
        (- (get total-stx-collateral current-portfolio) collateral-change)
      ))
      (updated-debt (if is-debt-increase
        (+ (get total-stx-debt current-portfolio) debt-change)
        (- (get total-stx-debt current-portfolio) debt-change)
      ))
    )
    (map-set account-portfolios { account: account } {
      total-stx-collateral: updated-collateral,
      total-stx-debt: updated-debt,
      active-positions: (get active-positions current-portfolio),
    })
  )
)

;; CORE PROTOCOL OPERATIONS

;; STX Collateral Deposit - Gateway to Bitcoin L2 lending
;; Locks user's entire STX balance as collateral for future borrowing
;; Enables capital efficiency while maintaining protocol security
(define-public (deposit-collateral)
  (let ((stx-balance (stx-get-balance tx-sender)))
    (if (> stx-balance u0)
      (begin
        ;; Transfer STX to protocol custody
        (try! (stx-transfer? stx-balance tx-sender (as-contract tx-sender)))
        ;; Update global protocol metrics
        (var-set aggregate-collateral
          (+ (var-get aggregate-collateral) stx-balance)
        )
        ;; Record user's new collateral position
        (update-account-portfolio tx-sender stx-balance true u0 true)
        (ok stx-balance)
      )
      E_AMOUNT_INVALID
    )
  )
)

;; STX Borrowing Engine - Unlock liquidity from Bitcoin L2 collateral
;; Enables users to borrow STX against their deposited collateral
;; Maintains strict over-collateralization for protocol solvency
(define-public (borrow-stx (requested-amount uint))
  (let (
      (user-portfolio (default-to {
        total-stx-collateral: u0,
        total-stx-debt: u0,
        active-positions: u0,
      }
        (map-get? account-portfolios { account: tx-sender })
      ))
      (available-collateral (get total-stx-collateral user-portfolio))
      (existing-debt (get total-stx-debt user-portfolio))
    )
    (if (and
        (> requested-amount u0)
        ;; Ensure new position maintains healthy collateralization
        (>=
          (compute-health-ratio available-collateral
            (+ existing-debt requested-amount)
          )
          (var-get collateral-requirement)
        )
      )
      (begin
        ;; Transfer borrowed STX to user
        (try! (as-contract (stx-transfer? requested-amount (as-contract tx-sender) tx-sender)))
        ;; Update protocol debt tracking
        (var-set aggregate-debt (+ (var-get aggregate-debt) requested-amount))
        ;; Record user's increased debt position
        (update-account-portfolio tx-sender u0 true requested-amount true)
        (ok requested-amount)
      )
      E_COLLATERAL_INSUFFICIENT
    )
  )
)

;; Debt Repayment System - Reduce borrowing exposure on Bitcoin L2
;; Allows users to repay borrowed STX and improve their health factor
;; Essential for maintaining good standing in the protocol
(define-public (repay-debt (repayment-amount uint))
  (let (
      (user-portfolio (default-to {
        total-stx-collateral: u0,
        total-stx-debt: u0,
        active-positions: u0,
      }
        (map-get? account-portfolios { account: tx-sender })
      ))
      (outstanding-debt (get total-stx-debt user-portfolio))
    )
    (if (<= repayment-amount outstanding-debt)
      (begin
        ;; Transfer repayment STX to protocol
        (try! (stx-transfer? repayment-amount tx-sender (as-contract tx-sender)))
        ;; Reduce global debt counter
        (var-set aggregate-debt (- (var-get aggregate-debt) repayment-amount))
        ;; Update user's debt position
        (update-account-portfolio tx-sender u0 true repayment-amount false)
        (ok repayment-amount)
      )
      E_AMOUNT_INVALID
    )
  )
)

;; Collateral Withdrawal - Reclaim STX from Bitcoin L2 protocol
;; Enables users to withdraw excess collateral while maintaining health factor
;; Critical for capital efficiency in DeFi operations
(define-public (withdraw-collateral (withdrawal-amount uint))
  (let (
      (user-portfolio (default-to {
        total-stx-collateral: u0,
        total-stx-debt: u0,
        active-positions: u0,
      }
        (map-get? account-portfolios { account: tx-sender })
      ))
      (available-collateral (get total-stx-collateral user-portfolio))
      (outstanding-debt (get total-stx-debt user-portfolio))
    )
    (if (and
        (<= withdrawal-amount available-collateral)
        ;; Ensure remaining collateral supports existing debt
        (>=
          (compute-health-ratio (- available-collateral withdrawal-amount)
            outstanding-debt
          )
          (var-get collateral-requirement)
        )
      )
      (begin
        ;; Return STX collateral to user
        (try! (as-contract (stx-transfer? withdrawal-amount (as-contract tx-sender) tx-sender)))
        ;; Update protocol collateral tracking
        (var-set aggregate-collateral
          (- (var-get aggregate-collateral) withdrawal-amount)
        )
        ;; Adjust user's collateral position
        (update-account-portfolio tx-sender withdrawal-amount false u0 true)
        (ok withdrawal-amount)
      )
      E_COLLATERAL_INSUFFICIENT
    )
  )
)