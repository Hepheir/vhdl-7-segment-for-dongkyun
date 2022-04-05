----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    13:09:25 02/01/2021
-- Design Name:
-- Module Name:    gbseg - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY gbseg IS
    PORT (
        RSTB : IN STD_LOGIC;
        CLK_50M : IN STD_LOGIC;
        DIGIT : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- 8 �����̵忡 ����, DIGIT�� 7 ���׸�Ʈ�� �����ϴ� ��ȣ�� ������ ������ �� �ִ�.
        SEG : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END gbseg;

ARCHITECTURE Behavioral OF gbseg IS

    SIGNAL clk_500 : STD_LOGIC;

BEGIN
    -----------------�ڸ� ���� Clock Generator : Clock 5MHz ----------------------
    -- https://m.blog.naver.com/pcs874/60102113193

    --    process ������ ��ȣ�ȿ� (clk,rst) �ΰ��� ��ȣ�̸��� �� �ֽ��ϴ�.
    --    �̰��� sensitivity�Դϴ�. ���� �ϴ� �� �̶�� �����ϸ� �˴ϴ�.
    --    �׷��ϱ� ��ȣ�� ���ϴ� ���� ���� �ִٰ� ��ȣ�� ���ϸ�
    --    ���μ��� �� ������ ���ͼ� ������ �Ѵٴ� �ǹ��Դϴ�.

    PROCESS (RSTB, CLK_50M)

        -- ī���� ���μ�����.

        -- slide has this comment
        -- 5000000 50M/5M=10HZ and 10HZ/2=5 HZ

        --	variable cnt : integer range 0 to 50000000;  -- ������ �� �ڸ�����
        ---	variable cnt : integer range 0 to 5000;  -- ���ÿ�
        VARIABLE cnt : INTEGER RANGE 0 TO 5000000; -- 50M/50K=1KHZ and 1KHZ/2=500 HZ
    BEGIN

        IF RSTB = '0' THEN
            cnt := 0;           -- variable �� ��쿡�� := �� �����
            clk_500 <= '0';     -- signal �� ��쿡�� <= �� �����

        ELSIF rising_edge (CLK_50M) THEN
            ---				if cnt >= 49999999 then             -- ������ �� �ڸ�����
            ---				if cnt >= 4999 then            -- ���ÿ�
            IF cnt >= 4999999 THEN -- �����۽�

                cnt := 0;
                clk_500 <= NOT clk_500; -- ���� ���߾� ��Ʈ ������.. -> 87�� ���� PROCESS �� ������.
                    -- 10HZ �� ���ŷ�, 1�ʿ� 10�� falling / rising edge �� �����ϰ� �ִ�, Digit Selection�� �ϰ��ִ� ��. 100ms

            ELSE
                cnt := cnt + 1;
                clk_500 <= clk_500; -- ����� ������ ����..

            END IF;

        END IF;

    END PROCESS;
    -------------------Digit selection-------------------------

    PROCESS (RSTB, clk_500) -- 87�� �� , yaw�� 0.1�ʿ� �� �� ȣ��ȴ�.

    BEGIN

        IF RSTB = '0' THEN -- ���� ���� �����̴�,
            --				DIGIT <= "1110";  -- �����ʿ��� ������
            DIGIT <= "0111"; -- �� ���� �ڸ� ����. �� ���ʺ��� ������.
        ELSIF rising_edge (clk_500) THEN -- ����¡�� �޸������� ����� ���� ������ 10/2 -> 5Hz �� �Ǿ����
            DIGIT <= DIGIT(0) & DIGIT(3 DOWNTO 1); -- ���� �ڸ� �̵� : -> �� �����̼� 0111 -> 1011 -> 1101
            --				DIGIT <=   DIGIT(2 downto 0) & DIGIT(3)  ; -- �����ʿ��� ����
            -- 0.2 �ʿ� �ѹ��� ���׸�Ʈ�� ���ʿ��� ���������� �ٲٸ� ������.
        END IF;

    END PROCESS;

    ------------- �� �ڸ����� ���� ǥ�� ----------------------------
    PROCESS (DIGIT)

    BEGIN

        CASE DIGIT IS
            -- Acitve low ***
                                -- .gfedcba  <- 7 ���׸�Ʈ
            WHEN "0111" => SEG <= "11111001"; --1 [1][ ][ ][ ]
            WHEN "1011" => SEG <= "10100100"; --2 [ ][2][ ][ ]
            WHEN "1101" => SEG <= "10110000"; --3 [ ][ ][3][ ]
            WHEN "1110" => SEG <= "10011001"; --4 [ ][ ][ ][4]
            WHEN OTHERS => SEG <= "11111111"; --  [1][2][3][4]

        END CASE;

    END PROCESS;

--==========================================================
END Behavioral;
