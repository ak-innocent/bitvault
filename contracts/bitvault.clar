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