module JuliaBLAS

using Base.BLAS
using Base.LinAlg: BlasComplex, BlasFloat, BlasReal, HermOrSym, UnitLowerTriangular, UnitUpperTriangular

import Base.LinAlg: A_mul_B!, Ac_mul_B!

export rankUpdate!

# Rank one update

## General
### BLAS
rankUpdate!{T<:BlasReal}(α::T, x::StridedVector{T}, y::StridedVector{T}, A::StridedMatrix{T}) = ger!(α, x, y, A)

### Generic
function rankUpdate!(α::Number, x::StridedVector, y::StridedVector, A::StridedMatrix)
    m, n = size(A, 1), size(A, 2)
    m == length(x) || throw(DimensionMismatch("x vector has wrong length"))
    n == length(y) || throw(DimensionMismatch("y vector has wrong length"))
    for j = 1:n
        yjc = y[j]'
        for i = 1:m
            A[i,j] += α*x[i]*yjc
        end
    end
end

## Hermitian
rankUpdate!{T<:BlasReal,S<:StridedMatrix}(α::T, a::StridedVector{T}, A::HermOrSym{T,S}) = syr!(A.uplo, α, a, A.data)
rankUpdate!{T<:BlasReal,S<:StridedMatrix}(a::StridedVector{T}, A::HermOrSym{T,S}) = rankUpdate!(one(T), a, A)

# Rank k update
## Real
rankUpdate!{T<:BlasReal,S<:StridedMatrix}(α::T, A::StridedMatrix{T}, β::T, C::HermOrSym{T,S}) = syrk!(C.uplo, 'N', α, A, β, C.data)
rankUpdate!{T<:Real,S<:StridedMatrix}(α::T, A::StridedMatrix{T}, C::HermOrSym{T,S}) = rankUpdate!(α, A, one(T), C)
rankUpdate!{T<:Real,S<:StridedMatrix}(A::StridedMatrix{T}, C::HermOrSym{T,S}) = rankUpdate!(one(T), A, one(T), C)

## Complex
rankUpdate!{T<:BlasReal,S<:StridedMatrix}(α::T, A::StridedMatrix{Complex{T}}, β::T, C::Hermitian{T,S}) = herk!(C.uplo, 'N', α, A, β, C.data)

# BLAS style A_mul_B!
## gemv
A_mul_B!{T<:BlasFloat}(α::T, A::StridedMatrix{T}, x::StridedVector{T}, β::T, y::StridedVector{T}) = gemv!('N', α, A, x, β, y)
Ac_mul_B!{T<:BlasFloat}(α::T, A::StridedMatrix{T}, x::StridedVector{T}, β::T, y::StridedVector{T}) = gemv!('C', α, A, x, β, y)

## gemm
A_mul_B!{T<:BlasFloat}(α::T, A::StridedMatrix{T}, B::StridedMatrix{T}, β::T, C::StridedMatrix{T}) = gemm!('N', 'N', α, A, B, β, C)
Ac_mul_B!{T<:BlasFloat}(α::T, A::StridedMatrix{T}, B::StridedMatrix{T}, β::T, C::StridedMatrix{T}) = gemm!('C', 'N', α, A, B, β, C)

## trmm
A_mul_B!{T<:BlasFloat,S}(α::T, A::UpperTriangular{T,S}, B::StridedMatrix{T}) = trmm!('L', 'U', 'N', 'N', α, A.data, B)
A_mul_B!{T<:BlasFloat,S}(α::T, A::LowerTriangular{T,S}, B::StridedMatrix{T}) = trmm!('L', 'L', 'N', 'N', α, A.data, B)
A_mul_B!{T<:BlasFloat,S}(α::T, A::UnitUpperTriangular{T,S}, B::StridedMatrix{T}) = trmm!('L', 'U', 'N', 'U', α, A.data, B)
A_mul_B!{T<:BlasFloat,S}(α::T, A::UnitLowerTriangular{T,S}, B::StridedMatrix{T}) = trmm!('L', 'L', 'N', 'U', α, A.data, B)
Ac_mul_B!{T<:BlasFloat,S}(α::T, A::UpperTriangular{T,S}, B::StridedMatrix{T}) = trmm!('L', 'U', 'C', 'N', α, A.data, B)
Ac_mul_B!{T<:BlasFloat,S}(α::T, A::LowerTriangular{T,S}, B::StridedMatrix{T}) = trmm!('L', 'L', 'C', 'N', α, A.data, B)
Ac_mul_B!{T<:BlasFloat,S}(α::T, A::UnitUpperTriangular{T,S}, B::StridedMatrix{T}) = trmm!('L', 'U', 'C', 'U', α, A.data, B)
Ac_mul_B!{T<:BlasFloat,S}(α::T, A::UnitLowerTriangular{T,S}, B::StridedMatrix{T}) = trmm!('L', 'L', 'C', 'U', α, A.data, B)
end