# 0004. CI は personal-products では必須、playground では任意にする

- Status: Accepted
- Date: 2026-11-03

## Context
個人プロジェクトの共通の型では「CI は必須にせず、規模と続けるかで判断」としていたが、判断の線がなく、CI があるリポジトリとないリポジトリが混ざっていた。リポジトリは `~/Documents/codes/` の下で、作品・公開を目指すもの（`personal-products/`）と試作（`playground/`）に分けている。

## Decision
`personal-products/` では CI を必須にし、`playground/` では任意にする。仕事のリポジトリは、仕事の相手のルールに従う。ひな形には CI のファイルを用意しておき、`playground/` では置くかを聞く。

## Consequences
- 見せる作品は、CI が通っていることが品質の証になる
- 試作は軽く始められる。試作から作品に移すときに CI を足す
- 全部を必須にする案は、試作を始めるときが重くなるので選ばなかった
