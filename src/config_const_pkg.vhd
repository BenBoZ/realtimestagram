--   This file is part of Realtimestagram.
--
--   Realtimestagram is free software: you can redistribute it and/or modify
--   it under the terms of the GNU General Public License as published by
--   the Free Software Foundation, either version 2 of the License, or
--   (at your option) any later version.
--
--   Realtimestagram is distributed in the hope that it will be useful,
--   but WITHOUT ANY WARRANTY; without even the implied warranty of
--   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--   GNU General Public License for more details.
--
--   You should have received a copy of the GNU General Public License
--   along with Realtimestagram.  If not, see <http://www.gnu.org/licenses/>.

--! Package for configuring project wide constants
package config_const_pkg is

    constant const_wordsize :integer := 8;      --! Number of bits per pixel 

    constant const_imageheight :integer := 512; --! Number of pixels wide for image pipeline
    constant const_imagewidth  :integer := 512; --! Number of pixels high for image pipeline
    
end config_const_pkg;
